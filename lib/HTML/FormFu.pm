package HTML::FormFu;
use strict;

use HTML::FormFu::Attribute qw/
    mk_attrs mk_attr_accessors mk_add_methods mk_single_methods
    mk_require_methods mk_get_methods mk_get_one_methods 
    mk_inherited_accessors mk_output_accessors
    mk_inherited_merging_accessors mk_accessors /;
use HTML::FormFu::Constraint;
use HTML::FormFu::Exception;
use HTML::FormFu::FakeQuery;
use HTML::FormFu::Filter;
use HTML::FormFu::Inflator;
use HTML::FormFu::Localize;
use HTML::FormFu::ObjectUtil qw/
    _single_element _require_constraint
    get_elements get_element get_all_elements get_all_element
    get_fields get_field get_errors get_error clear_errors
    populate load_config_file insert_before insert_after form
    _render_class clone stash constraints_from_dbic parent /;
use HTML::FormFu::Util qw/ require_class _get_elements xml_escape /;
use List::MoreUtils qw/ uniq /;
use Scalar::Util qw/ blessed refaddr weaken /;
use Storable qw/ dclone /;
use Regexp::Copy;
use Carp qw/ croak /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    '""'     => sub { return shift->render },
    bool     => sub {1},
    fallback => 1;

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_attr_accessors(qw/ id action enctype method /);

__PACKAGE__->mk_accessors(
    qw/ indicator filename javascript javascript_src
        element_defaults query_type languages force_error_message
        localize_class submitted query input _auto_fieldset
        _elements _processed_params _valid_names
        render_class_suffix /
);

__PACKAGE__->mk_output_accessors(qw/ form_error_message /);

__PACKAGE__->mk_inherited_accessors(
    qw/ auto_id auto_label auto_error_class auto_error_message
        auto_constraint_class auto_inflator_class auto_validator_class
        auto_transformer_class
        render_class render_class_prefix
        render_method
        render_processed_value force_errors /
);

__PACKAGE__->mk_inherited_merging_accessors(
    qw/ render_class_args config_callback / );

__PACKAGE__->mk_add_methods(
    qw/
        element deflator filter constraint inflator validator transformer /
);

__PACKAGE__->mk_single_methods(
    qw/
        deflator filter constraint inflator validator transformer /
);

__PACKAGE__->mk_require_methods(
    qw/
        deflator filter inflator validator transformer /
);

__PACKAGE__->mk_get_methods(
    qw/
        deflator filter constraint inflator validator transformer /
);

__PACKAGE__->mk_get_one_methods(
    qw/
        deflator filter constraint inflator validator tranformer /
);

*elements     = \&element;
*constraints  = \&constraint;
*filters      = \&filter;
*deflators    = \&deflator;
*inflators    = \&inflator;
*validators   = \&validator;
*transformers = \&transformer;
*loc          = \&localize;

our $VERSION = '0.01004';
$VERSION = eval $VERSION;

Class::C3::initialize();

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    my %defaults = (
        _elements           => [],
        _valid_names        => [],
        _processed_params   => {},
        input               => {},
        stash               => {},
        action              => '',
        method              => 'post',
        render_class_prefix => 'HTML::FormFu::Render',
        render_class_suffix => 'Form',
        render_class_args   => {},
        filename            => 'form',
        element_defaults    => {},
        render_method       => 'xhtml',
        query_type          => 'CGI',
        languages           => ['en'],
        localize_class      => 'HTML::FormFu::I18N',
        auto_error_class    => 'error_%s_%t',
        auto_error_message  => 'form_%s_%t',
    );

    $self->populate( \%defaults );

    $self->populate( \%attrs );

    return $self;
}

sub auto_fieldset {
    my $self = shift;

    return $self->_auto_fieldset if !@_;

    my %opts = ref $_[0] ? %{ $_[0] } : ();

    $opts{type} = 'Fieldset';

    $self->element( \%opts );

    $self->_auto_fieldset(1);

    return $self;
}

sub process {
    my $self = shift;

    $self->input(             {} );
    $self->_processed_params( {} );
    $self->_valid_names( [] );
    $self->clear_errors;

    my $query;
    if (@_) {
        $query = shift;
        $self->query($query);
    }
    else {
        $query = $self->query;
    }

    if ( defined $query && !blessed($query) ) {
        $query = HTML::FormFu::FakeQuery->new($query);

        $self->query($query);
    }

    for my $elem ( @{ $self->get_elements } ) {
        $elem->process;
    }

    my $submitted;

    if ( defined $query ) {
        eval { my @params = $query->param };
        croak "Invalid query object: $@" if $@;

        $submitted = $self->_submitted($query);
    }

    $self->submitted($submitted);

    return if !$submitted;

    my %params;

    for my $param ( $query->param ) {

        # don't allow names without a matching field
        next unless defined $self->get_field($param);

        my @values = $query->param($param);
        $params{$param} = @values > 1 ? \@values : $values[0];
    }

    for my $field ( @{ $self->get_fields } ) {
        $field->process_input( \%params );
    }

    $self->input( \%params );

    $self->_process_input;

    return;
}

sub _submitted {
    my ( $self, $query ) = @_;

    my $indi = $self->indicator;
    my $code;

    if ( defined($indi) && ref $indi ne 'CODE' ) {
        $code = sub { return defined $query->param($indi) };
    }
    elsif ( !defined $indi ) {
        my @names = uniq(
            map      { $_->name }
                grep { defined $_->name } @{ $self->get_fields } );

        $code = sub {
            grep { defined $query->param($_) } @names;
        };
    }
    else {
        $code = $indi;
    }

    return $code->( $self, $query );
}

sub _process_input {
    my ($self) = @_;

    $self->_build_params;

    $self->_process_file_uploads;

    $self->_filter_input;

    $self->_constrain_input;

    $self->_inflate_input
        if !@{ $self->get_errors };

    $self->_validate_input
        if !@{ $self->get_errors };

    $self->_transform_input
        if !@{ $self->get_errors };

    $self->_build_valid_names;

    return;
}

sub _build_params {
    my ($self) = @_;

    my $input = $self->input;
    my %params;

    my @names = uniq(
        sort
            map  { $_->name }
            grep { defined $_->name } @{ $self->get_fields } );

    for my $name (@names) {
        next if !exists $input->{$name};
        
        my $input = exists $input->{$name} ? $input->{$name} : undef;

        if ( ref $input eq 'ARRAY' ) {

            # can't clone upload filehandles
            # so create new arrayref of values
            $input = [@$input];
        }

        $params{$name} = $input;
    }

    $self->_processed_params( \%params );

    return;
}

sub _process_file_uploads {
    my ($self) = @_;

    my @names = uniq(
        sort
            map  { $_->name }
            grep { $_->isa('HTML::FormFu::Element::File') }
            grep { defined $_->name } @{ $self->get_fields } );

    if (@names) {
        my $query_class = $self->query_type;
        if ( $query_class !~ /^\+/ ) {
            $query_class = "HTML::FormFu::QueryType::$query_class";
        }
        require_class($query_class);

        my $params = $self->_processed_params;
        my $input  = $self->input;

        for my $name (@names) {
            next if !exists $input->{$name};

            my $values = $query_class->parse_uploads( $self, $name );

            $params->{$name} = $values;
        }
    }

    return;
}

sub _filter_input {
    my ($self) = @_;

    my $params = $self->_processed_params;

    for my $name ( keys %$params ) {
        next if !exists $self->input->{$name};
        
        for my $filter ( @{ $self->get_filters({ name => $name }) } ) {
            $filter->process( $self, $params );
        }
    }

    return;
}

sub _constrain_input {
    my ($self) = @_;

    my $params = $self->_processed_params;
    
    for my $constraint ( @{ $self->get_constraints } ) {
        
        my @errors = eval { $constraint->process($params); };
        
        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Constraint') ) {
            push @errors, $@;
        }
        elsif ($@) {
            push @errors, HTML::FormFu::Exception::Constraint->new;
        }

        for my $error (@errors) {
            $error->parent( $constraint->parent ) if !$error->parent;
            $error->constraint($constraint)       if !$error->constraint;

            $error->parent->add_error($error);
        }
    }

    return;
}

sub _inflate_input {
    my ($self) = @_;

    my $params = $self->_processed_params;

    for my $name ( keys %$params ) {
        next if !exists $self->input->{$name};
        
        next if $self->has_errors($name);

        my $value = $params->{$name};

        for my $inflator ( @{ $self->get_inflators({ name => $name }) } ) {
            my @errors;

            ( $value, @errors ) = eval { $inflator->process($value); };
            if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Inflator') ) {
                push @errors, $@;
            }
            elsif ($@) {
                push @errors, HTML::FormFu::Exception::Inflator->new;
            }

            for my $error (@errors) {
                $error->parent( $inflator->parent ) if !$error->parent;
                $error->inflator($inflator)         if !$error->inflator;

                $error->parent->add_error($error);
            }
        }

        $params->{$name} = $value;
    }

    return;
}

sub _validate_input {
    my ($self) = @_;

    my $params = $self->_processed_params;

    for my $name ( keys %$params ) {
        next if !exists $self->input->{$name};
        
        for my $validator ( @{ $self->get_validators({ name => $name }) } ) {
            next if $self->has_errors( $validator->field->name );
    
            my @errors = eval { $validator->process($params); };
            if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Validator') ) {
                push @errors, $@;
            }
            elsif ($@) {
                push @errors, HTML::FormFu::Exception::Validator->new;
            }
    
            for my $error (@errors) {
                $error->parent( $validator->parent ) if !$error->parent;
                $error->validator($validator)        if !$error->validator;
    
                $error->parent->add_error($error);
            }
        }
    }

    return;
}

sub _transform_input {
    my ($self) = @_;

    my $params = $self->_processed_params;

    for my $name ( keys %$params ) {
        next if !exists $self->input->{$name};
        
        my $value = $params->{$name};

        for my $transformer (
            @{ $self->get_transformers({ name => $name }) } )
        {
            next if $self->has_errors( $transformer->field->name );

            my @errors;

            ( $value, @errors )
                = eval { $transformer->process( $value, $params ); };
            if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Transformer') )
            {
                push @errors, $@;
            }
            elsif ($@) {
                push @errors, HTML::FormFu::Exception::Transformer->new;
            }

            for my $error (@errors) {
                $error->parent( $transformer->parent ) if !$error->parent;
                $error->transformer($transformer)      if !$error->transformer;

                $error->parent->add_error($error);
            }
        }

        $self->_processed_params->{$name} = $value;
    }

    return;
}

sub _build_valid_names {
    my ($self) = @_;

    my @errors = $self->has_errors;
    my @names;
    push @names, keys %{ $self->input };
    push @names, keys %{ $self->_processed_params };

    @names = uniq( sort @names );

    my %valid;
CHECK: for my $name (@names) {
        for my $error (@errors) {
            next CHECK if $name eq $error;
        }
        $valid{$name}++;
    }
    my @valid = keys %valid;

    $self->_valid_names( \@valid );

    return;
}

sub submitted_and_valid {
    my ($self) = @_;

    return $self->submitted && !$self->has_errors;
}

sub params {
    my ($self) = @_;

    return {} if !$self->submitted;

    my @names = $self->valid;
    my %params;

    for my $name (@names) {
        my @values = $self->param($name);
        if ( @values > 1 ) {
            $params{$name} = \@values;
        }
        else {
            $params{$name} = $values[0];
        }
    }

    return \%params;
}

sub param {
    my $self = shift;

    croak 'param method is readonly' if @_ > 1;

    return if !$self->submitted;

    if ( @_ == 1 ) {

        # only return a valid value
        my $name  = shift;
        my $valid = $self->valid($name);
        my $value = $self->_processed_params->{$name};

        if ( !defined $valid || !defined $value ) {
            return;
        }

        if ( ref $value eq 'ARRAY' ) {
            return wantarray ? @$value : $value->[0];
        }
        else {
            return $value;
        }
    }

    # return a list of valid names, if no $name arg
    return $self->valid;
}

sub valid {
    my $self = shift;

    return if !$self->submitted;

    my @valid = @{ $self->_valid_names };

    if (@_) {
        my $name = shift;
        return 1 if grep {/\Q$name/} @valid;
        return;
    }

    # return a list of valid names, if no $name arg
    return @valid;
}

sub has_errors {
    my $self = shift;

    return if !$self->submitted;

    my @names = map { $_->name }
        grep { @{ $_->get_errors } }
        grep { defined $_->name } @{ $self->get_fields };

    if (@_) {
        my $name = shift;
        return 1 if grep {/\Q$name/} @names;
        return;
    }

    # return list of names with errors, if no $name arg
    return @names;
}

sub add_valid {
    my ( $self, $key, $value ) = @_;

    croak 'add_valid requires arguments ($key, $value)' unless @_ == 3;

    $self->input->{$key} = $value;

    $self->_processed_params->{$key} = $value;

    push @{ $self->_valid_names }, $key
        if !grep { $_ eq $key } @{ $self->_valid_names };

    return $value;
}

sub render {
    my ($self) = @_;

    my $class = $self->_render_class;
    require_class($class);

    my $render = $class->new( {
            render_class_args   => $self->render_class_args,
            render_class_suffix => $self->render_class_suffix,
            render_method       => $self->render_method,
            filename            => $self->filename,
            javascript          => $self->javascript,
            javascript_src      => $self->javascript_src,
            force_error_message => $self->force_error_message,
            form_error_message  => xml_escape( $self->form_error_message ),
            _elements           => [ map { $_->render } @{ $self->_elements } ],
        } );

    $render->parent($self);

    $render->attributes( xml_escape $self->attributes );
    $render->stash( $self->stash );

    return $render;
}

sub start_form {
    return shift->render->start_form;
}

sub end_form {
    return shift->render->end_form;
}

sub hidden_fields {
    my ($self) = @_;

    return join "",
        map { $_->render } @{ $self->get_fields( { type => 'Hidden' } ) };
}

1;

__END__

=head1 NAME

HTML::FormFu - HTML Form Creation, Rendering and Validation Framework

=head1 BETA SOFTWARE

Please note that this is beta software.

There may be API changes required before the 1.0 release. Any incompatible 
changes will first be discussed on the L<mailing list|/SUPPORT>.

Work is still needed on the documentation, if you come across any errors or 
find something confusing, please give feedback via the 
L<mailing list|/SUPPORT>.

=head1 SYNOPSIS

    use HTML::FormFu;

    my $form = HTML::FormFu->new;
    
    $form->load_config_file('form.yml');

    $form->process( $cgi_query );

    if ( $form->submitted_and_valid ) {
        # do something with $form->params
    }
    else {
    	# display the form
        $template->param( form => $form );
    }

Here's an example of a config file to create a basic login form (all examples 
here are L<YAML>, but you can use any format supported by L<Config::Any>), 
you can also create forms directly in your perl code, rather than using an 
external config file.

    ---
    action: /login
    indicator: submit
    auto_fieldset: 1
    
    elements:
      - type: Text
        name: user
        constraints: 
          - Required
      
      - type: Password
        name: pass
        constraints:
          - Required
      
      - type: Submit
        name: submit
    
    constraints:
      - SingleValue

=head1 DESCRIPTION

L<HTML::FormFu> is a HTML form framework which aims to be as easy as 
possible to use for basic web forms, but with the power and flexibility to 
do anything else you might want to do (as long as it involves forms).

You can configure almost any part of formfu's behaviour and output. By 
default formfu renders "XHTML 1.0 Strict" compliant markup, with as little 
extra markup as possible, but with sufficient CSS class names to allow for a 
wide-range of output styles to be generated by changing only the CSS.

All methods listed below (except L</new>) can either be called as a normal 
method on your C<$form> object, or as an option in your config file. Examples 
will mainly be shown in L<YAML> config syntax.

This documentation follows the convention that method arguments surrounded 
by square brackets C<[]> are I<optional>, and all other arguments are 
required.

=head1 GETTING STARTED

HTML::FormFu uses a templating system such as L<Template::Toolkit|Template> 
or L<Template::Alloy> to create the form's XHTML output. As such, it needs 
to be able to find it's own template files. If you're using the L<Catalyst> 
web framework, just run the following command:

    $ script/myapp_create.pl HTML::FormFu

This will create a directory, C<root/formfu>, containing the HTML::FormFu 
template files. If you also use L<Catalyst::Controller::HTML::FormFu>, this 
will also use that directory by default.

If you're not using L<Catalyst>, you can create the template files by 
running the following command (while in the directory containing your CGI 
programs):

    $ html_formfu_deploy.pl

This installs the templates files in directory C<./root>, which is the 
default path that HTML::FormFu searches in.

Although HTML::FormFu uses L<Template::Toolkit|Template> internally, 
HTML::FormFu can be used in conjunction with whichever other templating 
system you prefer to use for your own page layouts, whether it's 
L<HTML::Template>, C<< <TMPL_VAR form> >>, 
L<Petal>, C<< <form tal:replace="form"></form> >> 
or L<Template::Magic>, C<< <!-- {form} --> >>.

=head1 BUILDING A FORM

=head2 new

Arguments: [\%options]

Return Value: $form

Create a new L<HTML::FormFu|HTML::FormFu> object.

Any method which can be called on the L<HTML::FormFu|HTML::FormFu> object may 
instead be passed as an argument to L</new>.

    my $form = HTML::FormFu->new({
        action        => '/search',
        method        => 'GET',
        auto_fieldset => 1,
    });

=head2 load_config_file

Arguments: $filename

Arguments: \@filenames

Return Value: $form

Accepts a filename or list of file names, whose filetypes should be of any 
format recognized by L<Config::Any>.

The content of each config file is passed to L</populate>, and so are added 
to the form.

L</load_config_file> may be called in a config file itself, as so allow 
common settings to be kept in a single config file which may be loaded 
by any form.

See L</BEST PRACTICES> for advice on organising config files.

=head2 config_callback

Arguments: \%options

If defined, the arguments are used to create a L<Data::Visitor::Callback> 
object during L</load_config_file> which may be used to pre-process the 
config before it is sent to L</populate>

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 populate

Arguments: \%options

Return Value: $form

Each option key/value passed may be any L<HTML::FormFu|HTML::FormFu> 
method-name and arguments.

Provides a simple way to set multiple values, or add multiple elements to 
a form with a single method-call.

=head2 indicator

Arguments: $field_name

Arguments: \&coderef

If L</indicator> is set to a fieldname, L</submitted> will return true if 
a value for that fieldname was submitted.

If L</indicator> is set to a code-ref, it will be called as a subroutine 
with the two arguments C<$form> and C<$query>, and it's return value will be 
used as the return value for L</submitted>.

If L</indicator> is not set, </submitted> will return true if a value for 
any known fieldname was submitted.

=head2 auto_fieldset

Arguments: 1

Arguments: \%options

Return Value: $fieldset

This setting is suitable for most basic forms, and means you can generally
ignore adding fieldsets yourself.

Calling C<< $form->auto_fieldset(1) >> immediately adds a fieldset element to 
the form. Thereafter, C<< $form->elements() >> will add all elements (except 
fieldsets) to that fieldset, rather than directly to the form.

To be specific, the elements are added to the L<last> fieldset on the form, 
so if you add another fieldset, any further elements will be added to that 
fieldset.

Also, you may pass a hashref to auto_fieldset(), and this will be used
to set defaults for the first fieldset created.

A few examples and their output, to demonstrate:

2 elements with no fieldset.

    ---
    elements:
      - type: Text
        name: foo
      - type: Text
        name: bar

    <form action="" method="post">
      <span class="text">
        <input name="foo" type="text" />
      </span>
      <span class="text">
        <input name="bar" type="text" />
      </span>
    </form>

2 elements with an L</auto_fieldset>.

    ---
    auto_fieldset: 1
    elements:
      - type: Text
        name: foo
      - type: Text
        name: bar

    <form action="" method="post">
      <fieldset>
        <span class="text">
          <input name="foo" type="text" />
        </span>
        <span class="text">
          <input name="bar" type="text" />
        </span>
      </fieldset>
    </form>

The 3rd element is within a new fieldset

    ---
    auto_fieldset: { id: fs }
    elements:
      - type: Text
        name: foo
      - type: Text
        name: bar
      - type: Fieldset
      - type: Text
        name: baz

    <form action="" method="post">
      <fieldset id="fs">
        <span class="text">
          <input name="foo" type="text" />
        </span>
        <span class="text">
          <input name="bar" type="text" />
        </span>
      </fieldset>
      <fieldset>
        <span class="text">
          <input name="baz" type="text" />
        </span>
      </fieldset>
    </form>

Because of this behaviour, if you want nested fieldsets you will have to add 
each nested fieldset directly to it's intended parent.

    my $parent = $form->get_element({ type => 'Fieldset' });
    
    $parent->element('fieldset');

=head2 form_error_message

Arguments: $string

Normally, input errors cause an error message to be displayed alongside the 
appropriate form field. If you'd also like a general error message to be 
displayed at the top of the form, you can set the message with 
L</form_error_message>.

To change the markup used to display the message, edit the 
C<form_error_message> template file.

=head2 form_error_message_xml

Arguments: $string

If you don't want your error message to be XML-escaped, use the 
L</form_error_message_xml> method instead.

=head2 form_error_message_loc

Arguments: $localization_key

For ease of use, if you'd like to use the provided localized error message, 
set L</form_error_message_loc> to the value C<form_error_message>.

You can, of course, set L</form_error_message_loc> to any key in your L10N 
file.

=head1 force_error_message

If true, forces the L</form_error_message> to be displayed even if there are 
no field errors.

=head2 element_defaults

Arguments: \%defaults

Set defaults which will be added to every element of that type which is added 
to the form.

For example, to make every C<text> element automatically have a 
L<size|HTML::FormFu::Element/size> of C<10>, and make every C<textarea> 
element automatically get a class-name of C<bigbox>:

    element_defaults:
      Text:
        size: 10
      Textarea:
        add_attributes:
          class: bigbox

=head2 javascript

Arguments: [$javascript]

If set, the contents will be rendered within a C<script> tag, inside the top 
of the form.

=head2 stash

Arguments: [\%private_stash]

Provides a hash-ref in which you can store any data you might want to 
associate with the form. This data will not be used by 
L<HTML::FormFu|HTML::FormFu> at all.

=head2 elements

=head2 element

Arguments: $type

Arguments: \%options

Return Value: $element

Arguments: \@arrayref_of_types_or_options

Return Value: @elements

Adds a new element to the form. See 
L<HTML::FormFu::Element/"CORE ELEMENTS"> for a list of core elements.

If you want to load an element from a namespace other than 
C<HTML::FormFu::Element::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

    ---
    elements:
      - type: +MyApp::CustomElement
        name: foo

If a C<type> is not provided in the C<\%options>, the default C<text> will 
be used.

L</element> is an alias for L</elements>.

=head2 deflators

=head2 deflator

Arguments: $type

Arguments: \%options

Return Value: $deflator

Arguments: \@arrayref_of_types_or_options

Return Value: @deflators

A L<deflator|HTML::FormFu::Deflator> may be associated with any form field, 
and allows you to provide 
L<< $field->default|HTML:FormFu::Element::_Field/default >> with a value 
which may be an object.

If an object doesn't stringify to a suitable value for display, the 
L<deflator|HTML::FormFu::Deflator> can ensure that the form field 
receives a suitable string value instead.

See L<HTML::FormFu::Deflator/"CORE DEFLATORS"> for a list of core deflators.

If a C<name> attribute isn't provided, a new deflator is created for and 
added to every field on the form.

If you want to load a filter in a namespace other than 
C<HTML::FormFu::Deflator::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</deflator> is an alias for L</deflators>.

=head1 FORM LOGIC AND VALIDATION

L<HTML::FormFu|HTML::FormFu> provides several stages for what is 
traditionally described as I<validation>. These are:

=over

=item L<HTML::FormFu::Filter|HTML::FormFu::Filter>

=item L<HTML::FormFu::Constraint|HTML::FormFu::Constraint>

=item L<HTML::FormFu::Inflator|HTML::FormFu::Inflator>

=item L<HTML::FormFu::Validator|HTML::FormFu::Validator>

=item L<HTML::FormFu::Transformer|HTML::FormFu::Transformer>

=back

The first stage, the filters, allow for cleanup of user-input, such as 
encoding, or removing leading/trailing whitespace, or removing non-digit 
characters from a creditcard number.

All of the following stages allow for more complex processing, and each of 
them have a mechanism to allow exceptions to be thrown, to represent input 
errors. In each stage, all form fields must be processed without error for 
the next stage to proceed. If there were any errors, the form should be 
re-displayed to the user, to allow them to input correct values.

Constraints are intended for low-level validation of values, such as 
"is this value within bounds" or "is this a valid email address".

Inflators are intended to allow a value to be turned into an appropriate 
object. The resulting object will be passed to subsequent Validators and 
Transformers, and will also be returned by L</params> and L</param>.

Validators allow for a more complex validation than Constraints. Validators 
can be sure that all values have successfully passed all Constraints and have 
been successfully passed through all Inflators. It is expected that most 
Validators will be application-specific, and so each will be implemented as 
a seperate class written by the HTML::FormFu user.

=head2 filters

=head2 filter

Arguments: $type

Arguments: \%options

Return Value: $filter

Arguments: \@arrayref_of_types_or_options

Return Value: @filters

If you provide a C<name> or C<names> value, the filter will be added to 
just that named field.
If you do not provide a C<name> or C<names> value, the filter will be added 
to all L<fields|HTML::FormFu::Element::_Field> already attached to the form. 

See L<HTML::FormFu::Filter/"CORE FILTERS"> for a list of core filters.

If a C<name> attribute isn't provided, a new filter is created for and 
added to every field on the form.

If you want to load a filter in a namespace other than 
C<HTML::FormFu::Filter::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</filter> is an alias for L</filters>.

=head2 constraints

=head2 constraint

Arguments: $type

Arguments: \%options

Return Value: $constraint

Arguments: \@arrayref_of_types_or_options

Return Value: @constraints

See L<HTML::FormFu::Constraint/"CORE CONSTRAINTS"> for a list of core 
constraints.

If a C<name> attribute isn't provided, a new constraint is created for and 
added to every field on the form.

If you want to load a constraint in a namespace other than 
C<HTML::FormFu::Constraint::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</constraint> is an alias for L</constraints>.

=head2 inflators

=head2 inflator

Arguments: $type

Arguments: \%options

Return Value: $inflator

Arguments: \@arrayref_of_types_or_options

Return Value: @inflators

See L<HTML::FormFu::Inflator/"CORE INFLATORS"> for a list of core inflators.

If a C<name> attribute isn't provided, a new inflator is created for and 
added to every field on the form.

If you want to load a inflator in a namespace other than 
C<HTML::FormFu::Inflator::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</inflator> is an alias for L</inflators>.

=head2 validators

=head2 validator

Arguments: $type

Arguments: \%options

Return Value: $validator

Arguments: \@arrayref_of_types_or_options

Return Value: @validators

See L<HTML::FormFu::Validator/"CORE VALIDATORS"> for a list of core 
validators.

If a C<name> attribute isn't provided, a new validator is created for and 
added to every field on the form.

If you want to load a validator in a namespace other than 
C<HTML::FormFu::Validator::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</validator> is an alias for L</validators>.

=head2 transformers

=head2 transformer

Arguments: $type

Arguments: \%options

Return Value: $transformer

Arguments: \@arrayref_of_types_or_options

Return Value: @transformers

See L<HTML::FormFu::Transformer/"CORE TRANSFORMERS"> for a list of core 
transformers.

If a C<name> attribute isn't provided, a new transformer is created for and 
added to every field on the form.

If you want to load a transformer in a namespace other than 
C<HTML::FormFu::Transformer::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

L</transformer> is an alias for L</transformers>.

=head1 FORM ATTRIBUTES

All attributes are added to the rendered form's start tag.

=head2 attributes

=head2 attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

Accepts either a list of key/value pairs, or a hash-ref.

    ---
    attributes:
      id: form
      class: fancy_form

As a special case, if no arguments are passed, the attributes hash-ref is 
returned. This allows the following idioms.

    # set a value
    $form->attributes->{id} = 'form';
    
    # delete all attributes
    %{ $form->attributes } = ();

L</attrs> is an alias for L</attributes>.

=head2 attributes_xml

=head2 attrs_xml

Provides the same functionality as L<"/attributes">, but values won't be 
XML-escaped.

L</attrs_xml> is an alias for L</attributes_xml>.

=head2 add_attributes

=head2 add_attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

Accepts either a list of key/value pairs, or a hash-ref.

    $form->add_attributes( $key => $value );
    $form->add_attributes( { $key => $value } );

All values are appended to existing values, with a preceeding space 
character. This is primarily to allow the easy addition of new class names.

    $form->attributes({ class => 'foo' });
    
    $form->add_attributes({ class => 'bar' });
    
    # class is now 'foo bar'

L</add_attrs> is an alias for L</add_attributes>.

=head2 add_attributes_xml

=head2 add_attrs_xml

Provides the same functionality as L<"/add_attributes">, but values won't be 
XML-escaped.

L</add_attrs_xml> is an alias for L</add_attributes_xml>.

=head2 del_attributes

=head2 del_attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

Accepts either a list of key/value pairs, or a hash-ref.

    $form->del_attributes( $key => $value );
    $form->del_attributes( { $key => $value } );

All values are removed from the attribute value.

    $form->attributes({ class => 'foo bar' });
    
    $form->del_attributes({ class => 'bar' });
    
    # class is now 'foo'

L</del_attrs> is an alias for L</del_attributes>.

=head2 del_attributes_xml

=head2 del_attrs_xml

Provides the same functionality as L<"/del_attributes">, but values won't be 
XML-escaped.

L</del_attrs_xml> is an alias for L</del_attributes_xml>.

The following methods are shortcuts for accessing L<"/attributes"> keys.

=head2 id

Arguments: [$id]

Return Value: $id

Get or set the form's DOM id.

Default Value: none

=head2 action

Arguments: [$uri]

Return Value: $uri

Get or set the action associated with the form. The default is no action,  
which causes most browsers to submit to the current URI.

Default Value: ""

=head2 enctype

Arguments: [$enctype]

Return Value: $enctype

Get or set the encoding type of the form. Valid values are 
C<application/x-www-form-urlencoded> and C<multipart/form-data>.

If the form contains a File element, the enctype is automatically set to
C<multipart/form-data>.

=head2 method

Arguments: [$method]

Return Value: $method

Get or set the method used to submit the form. Can be set to either "post" 
or "get".

Default Value: "post"

=head1 CSS CLASSES

=head2 auto_id

Arguments: [$string]

If set, then all form fields will be given an auto-generated 
L<id|HTML::FormFu::Element/id> attribute, if it doesn't have one already.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_label

Arguments: [$string]

If set, then all form fields will be given an auto-generated 
L<name|HTML::FormFu::Element::Field/label>, if it doesn't have one already.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>.

The generated string will be passed to L</localize> to create the label.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_error_class

Arguments: [$string]

If set, then all form errors will be given an auto-generated class-name.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>, C<%s> will be replaced 
by L<< $error->stage >>.

Default Value: 'error_%s_%t'

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_error_message

Arguments: [$string]

If set, then all form fields will be given an auto-generated 
L<message|HTML::FormFu::Exception::Input/message>, if it doesn't have one 
already.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>.

The generated string will be passed to L</localize> to create the message.

Default Value: 'form_%t_error'

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_constraint_class

Arguments: [$string]

If set, then all form fields will be given an auto-generated class-name 
for each associated constraint.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_inflator_class

Arguments: [$string]

If set, then all form fields will be given an auto-generated class-name 
for each associated inflator.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_validator_class

Arguments: [$string]

If set, then all form fields will be given an auto-generated class-name 
for each associated validator.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 auto_transformer_class

Arguments: [$string]

If set, then all form fields will be given an auto-generated class-name 
for each associated validator.

The following character substitution will be performed: C<%f> will be 
replaced by L<< $form->id|/id >>, C<%n> will be replaced by 
L<< $field->name|HTML::FormFu::Element/name >>, C<%t> will be replaced by 
L<< lc( $field->type )|HTML::FormFu::Element/type >>.

Default Value: not defined

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head1 LOCALIZATION

=head2 languages

Arguments: [\@languages]

A list of languages which will be passed to the localization object.

Default Value: ['en']

=head2 localize_class

Arguments: [$class_name]

Classname to be used for the default localization object.

Default Value: 'HTML::FormFu::I18N'

=head2 localize

=head2 loc

Arguments: [$key, @arguments]

Compatible with the C<maketext> method in L<Locale::Maketext>.

=head1 PROCESSING A FORM

=head2 query

Arguments: [$query_object]

Arguments: \%params

Provide a L<CGI> compatible query object or a hash-ref of submitted 
names/values. Alternatively, the query object can be passed directly to the 
L</process> object.

=head2 query_type

Arguments: [$query_type]

Set which module is being used to provide the L</query>.

The L<Catalyst::Controller::HTML::FormFu> automatically sets this to 
C<Catalyst>.

Valid values are C<CGI>, C<Catalyst> and C<CGI::Simple>.

Default Value: 'CGI'

=head2 process

Arguments: [$query_object]

Arguments: [\%params]

Process the provided query object or input values. This must be called 
before calling any of the methods listed under 
L</"SUBMITTED FORM VALUES AND ERRORS"> and L</"MODIFYING A SUBMITTED FORM">.

It's not necessary to call L</process> before printing the form or calling 
L</render>.

=head1 SUBMITTED FORM VALUES AND ERRORS

=head2 submitted

Returns true if the form has been submitted. See L</indicator> for details 
on how this is computed.

=head2 submitted_and_valid

Shorthand for C<< $form->submitted && !$form->has_errors >>

=head2 params

Return Value: \%params

Returns a hash-ref of all valid input for which there were no errors.

=head2 param

Arguments: [$field_name]

Return Value: $input_value

Return Value: @valid_names

A (readonly) L<CGI> compatible method.

If a field name if given, in list-context returns any valid values submitted 
for that field, and in scalar-context returns only the first of any valid 
values submitted for that field.

If no argument is given, returns a list of all valid input field names 
without errors.

Passing more than 1 argument is a fatal error. 

=head2 valid

Arguments: [$field_name]

Return Value: @valid_names

Return Value: $bool

If a field name if given, returns C<true> if that field had no errors and 
C<false> if there were errors.

If no argument is given, returns a list of all valid input field names 
without errors.

=head2 has_errors

Arguments: [$field_name]

Return Value: @names

Return Value: $bool

If a field name if given, returns C<true> if that field had errors and 
C<false> if there were no errors.

If no argument is given, returns a list of all input field names with errors.

=head2 get_errors

Arguments: [%options]

Arguments: [\%options]

Return Value: \@errors

Returns an array-ref of exception objects from all fields in the form.

Accepts both C<name>, C<type> and C<stage> arguments to narrow the returned 
results.

    $form->get_errors({
        name  => 'foo',
        type  => 'Regex',
        stage => 'constraint'
    });

=head2 get_error

Arguments: [%options]

Arguments: [\%options]

Return Value: $error

Accepts the same arguments as L</get_errors>, but only returns the first 
error found.

=head1 MODIFYING A SUBMITTED FORM

=head2 add_valid

Arguments: $name, $value

Return Value: $value

The provided value replaces any current value for the named field. This 
value will be returned in subsequent calls to L</params> and L</param> and 
the named field will be included in calculations for L</valid>.

=head2 clear_errors

Deletes all errors from a submitted form.

=head1 RENDERING A FORM

=head2 render

Return Value: $render_object

Returns a C<$render> object which can either be printed, or used for more 
advanced custom rendering.

Using a C<$form> object in string context (for example, printing it) 
automatically calls L</render>.

The default class of the returned render object is 
L<HTML::FormFu::Render::Form>.

=head2 start_form

Return Value: $string

Convenience method for returning L<HTML::FormFu::Render::Form/start_form>.

Returns the form start tag, and any output of L</form_error_message> and 
L</javascript>.

Equivalent to:

    $form->render->start_form;

=head2 end_form

Return Value: $string

Convenience method for returning L<HTML::FormFu::Render::Form/end_form>.

Returns the form end tag.

Equivalent to:

    $form->render->end_form;

=head2 hidden_fields

Return Value: $string

Returns all hidden form fields.

=head1 ADVANCED CUSTOMISATION

=head2 filename

Change the template filename used for the form.

Default Value: "form"

=head2 render_class

Set the classname used to create a form render object. If set, the values of 
L</render_class_prefix> and L</render_class_suffix> are ignored.

Default Value: none

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 render_class_prefix

Set the prefix used to generate the classname of the form render object and 
all Element render objects.

Default Value: "HTML::FormFu::Render"

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 render_class_suffix

Set the suffix used to generate the classname of the form render object.

Default Value: "Form"

=head2 render_class_args

Arguments: [\%constructor_arguments]

Accepts a hash-ref of arguments passed to the render object constructor for 
the form and all elements.

The default render class (L<HTML::FormFu::Render::Base>) passes these 
arguments to the L<TT|Template> constructor.

The keys C<RELATIVE> and C<RECURSION> are overridden to always be true, as 
these are a basic requirement for the L<Template> engine.

The default value of C<INCLUDE_PATH> is C<root>. This should generally be 
overridden to point to the location of the HTML::FormFu template files on 
your local system.

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head2 render_method

Arguments: [$method_name]

The method named called by L<HTML::FormFu::Render::base/output>.

Default Value: 'xhtml'

This method is a special 'inherited accessor', which means it can be set on 
the form, a block element or a single element. When the value is read, if 
no value is defined it automatically traverses the element's hierarchy of 
parents, through any block elements and up to the form, searching for a 
defined value.

=head1 INTROSPECTION

=head2 get_elements

Arguments: [%options]

Arguments: [\%options]

Return Value: \@elements

Returns all top-level elements in the form (not recursive).

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_elements({
        name => 'foo',
        type => 'Radio',
    });

See L</get_all_elements> for a recursive version.

=head2 get_element

Arguments: [%options]

Arguments: [\%options]

Return Value: $element

Accepts the same arguments as L</get_elements>, but only returns the first 
element found.

=head2 get_all_elements

=head2 get_fields

Arguments: [%options]

Arguments: [\%options]

Return Value: \@elements

Returns all fields in the form (specifically, all elements which have a true 
L<HTML::FormFu::Element/is_field> value.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_fields({
        name => 'foo',
        type => 'Radio',
    });

=head2 get_field

Arguments: [%options]

Arguments: [\%options]

Return Value: $element

Accepts the same arguments as L</get_fields>, but only returns the first 
field found.

=head2 get_deflators

Arguments: [%options]

Arguments: [\%options]

Return Value: \@deflators

Returns all top-level deflators from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_deflators({
        name => 'foo',
        type => 'Strftime',
    });

=head2 get_deflator

Arguments: [%options]

Arguments: [\%options]

Return Value: $element

Accepts the same arguments as L</get_deflators>, but only returns the first 
deflator found.

=head2 get_filters

Arguments: [%options]

Arguments: [\%options]

Return Value: \@filters

Returns all top-level filters from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_filters({
        name => 'foo',
        type => 'LowerCase',
    });

=head2 get_filter

Arguments: [%options]

Arguments: [\%options]

Return Value: $filter

Accepts the same arguments as L</get_filters>, but only returns the first 
filter found.

=head2 get_constraints

Arguments: [%options]

Arguments: [\%options]

Return Value: \@constraints

Returns all constraints from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_constraints({
        name => 'foo',
        type => 'Equal',
    });

=head2 get_constraint

Arguments: [%options]

Arguments: [\%options]

Return Value: $constraint

Accepts the same arguments as L</get_constraints>, but only returns the 
first constraint found.

=head2 get_inflators

Arguments: [%options]

Arguments: [\%options]

Return Value: \@inflators

Returns all inflators from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_inflators({
        name => 'foo',
        type => 'DateTime',
    });

=head2 get_inflator

Arguments: [%options]

Arguments: [\%options]

Return Value: $inflator

Accepts the same arguments as L</get_inflators>, but only returns the 
first inflator found.

=head2 get_validators

Arguments: [%options]

Arguments: [\%options]

Return Value: \@validators

Returns all validators from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_validators({
        name => 'foo',
        type => 'Callback',
    });

=head2 get_validator

Arguments: [%options]

Arguments: [\%options]

Return Value: $validator

Accepts the same arguments as L</get_validators>, but only returns the 
first validator found.

=head2 get_transformers

Arguments: [%options]

Arguments: [\%options]

Return Value: \@transformers

Returns all transformers from all fields.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_transformers({
        name => 'foo',
        type => 'Callback',
    });

=head2 get_transformer

Arguments: [%options]

Arguments: [\%options]

Return Value: $transformer

Accepts the same arguments as L</get_transformers>, but only returns the 
first transformer found.

=head2 clone

Returns a deep clone of the <$form> object.

Because of scoping issues, code references (such as in Callback constraints) 
are copied instead of cloned.

=head1 BEST PRACTICES

It is advisable to keep application-wide (or global) settings in a single 
config file, which should be loaded by each form.

See L</load_config_file>.

=head1 EXAMPLES

=head2 vertically-aligned CSS

The distribution directory C<examples/vertically-aligned> contains a form with 
example CSS for a "vertically aligned" theme.

This can be viewed by opening the file C<vertically-aligned.html> in a 
web-browser.

If you wish to experiment with making changes, the form is defined in file 
C<vertically-aligned.yml>, and the HTML file can be updated with any changes 
by running the following command (while in the distribution root directory).

    perl examples/vertically-aligned/vertically-aligned.pl

This uses the C<Template Toolkit|Template> file C<vertically-aligned.tt>, 
and the CSS is defined in files C<vertically-aligned.css> and 
C<vertically-aligned-ie.css>.

=head1 FREQUENTLY ASKED QUESTIONS (FAQ)

=head2 It's too slow!

Are you using L<Catalyst::Plugin::StackTrace>? This is known to 
cause performance problems, and we advise disabling it.

You can also tell HTML::FormFu to use L<Template::Alloy> instead of 
L<Template::Toolkit|Template>, it's mostly compatible, and in most cases 
provides a reasonable speed increase. You can do this either by setting the 
C<HTML_FORMFU_TEMPLATE_ALLOY> environment variable to a true value, or with 
the following yaml config:

    render_class_args:
      TEMPLATE_ALLOY: 1

=head2 How do I add an onSubmit handler to the form?

    ---
    attributes_xml: { onsubmit: $javascript }

See L<HTML::FormFu/attributes>.

=head2 How do I add an onChange handler to a form field?

    ---
    elements:
      - type: Text
        attributes_xml: { onchange: $javascript }

See L<HTML::FormFu::Element/attributes>.

=head2 Element X does not have an accessor for Y!

You can add any arbitrary HTML attributes with 
L<HTML::FormFu::Element/attributes>.

=head2 How can I add a HTML tag which isn't included?

You can use the L<HTML::FormFu::Element::Block> element, and set
the L<tag|HTML::FormFu::Element::Block/tag> to the tag type you want.

    ---
    elements:
      - type: Block
        tag: span

=head2 How do I check if a textfield contains a URI in a proper format?

Use HTML::FormFu::Constraint::Regex:

    ---
    elements:
        - type: Text
          name: uri
          constraint:
            - type: Regex
              common: [ URI, HTTP, { '-scheme': 'ftp|https?' ]

=head2 If a user enters a value like "  foo  " and we need to redisplay the form, I would like the prefilled value to be "foo".

First you have to use the TrimEdges Filter.

Second to get this behaviour, set 'render_processed_value' to a true value.

You can set this at the form level to effect all fields, or set it at
the fieldset- or field-level.

One thing to beware is if you have Inflators on a field that create an
object, you'll need to ensure either that the object stringifies
correctly, or set "render_processed_value = 0" for that particular
field.

=head1 SUPPORT

Project Page:

L<http://code.google.com/p/html-formfu/>

Mailing list:

L<http://lists.scsys.co.uk/cgi-bin/mailman/listinfo/html-formfu>

Mailing list archives:

L<http://lists.scsys.co.uk/pipermail/html-formfu/>

The L<HTML::Widget archives|http://lists.scsys.co.uk/pipermail/html-widget/> 
between January and May 2007 also contain discussion regarding HTML::FormFu.

=head1 BUGS

Please submit bugs / feature requests to 
L<http://code.google.com/p/html-formfu/issues/list> (preferred) or 
L<http://rt.perl.org>.

=head1 SUBVERSION REPOSITORY

The publicly viewable subversion code repository is at 
L<http://html-formfu.googlecode.com/svn/trunk/HTML-FormFu>.

If you wish to contribute, you'll need a GMAIL email address. Then just 
ask on the mailing list for commit access.

If you wish to contribute but for some reason really don't want to sign up 
for a GMAIL account, please post patches to the mailing list (although  
you'll have to wait for someone to commit them). 

If you have commit permissions, use the HTTPS repository url: 
L<https://html-formfu.googlecode.com/svn/trunk/HTML-FormFu>

=head1 SEE ALSO

L<HTML::FormFu::Dojo>

L<HTML::FormFu::Imager>

L<Catalyst::Controller::HTML::FormFu>

L<DBIx::Class::FormFu>

=head1 AUTHORS

Carl Franks

=head1 CONTRIBUTORS

Brian Cassidy

Daisuke Maki

Andreas Marienborg

Mario Minati

Based on the original source code of L<HTML::Widget>, by Sebastian Riedel, 
C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

