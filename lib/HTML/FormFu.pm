package HTML::FormFu;
use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_inherited_accessors );
use HTML::FormFu::Attribute qw/ mk_attrs mk_attr_accessors /;
use HTML::FormFu::Constraint;
use HTML::FormFu::Exception;
use HTML::FormFu::FakeQuery;
use HTML::FormFu::Filter;
use HTML::FormFu::Inflator;
use HTML::FormFu::ObjectUtil
    qw/ element constraint filter deflator inflator
    get_elements get_element get_all_elements get_fields get_field 
    get_constraints get_constraint get_filters get_filter  
    get_deflators get_deflator get_inflators get_inflator
    get_errors get_error delete_errors
    populate load_config_file insert_after form
    _render_class clone stash /;
use HTML::FormFu::Util qw/ _parse_args require_class _get_elements xml_escape /;
use List::MoreUtils qw/ uniq /;
use Scalar::Util qw/ blessed weaken /;
use Storable qw/ dclone /;
use Regexp::Copy;
use Carp qw/ croak /;

use overload
    '""' => sub { return shift->render },
    bool => sub {1};

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_attr_accessors(qw/ id action enctype method /);

__PACKAGE__->mk_accessors(
    qw/ parent
        render_class render_class_prefix render_class_suffix render_class_args 
        render_method
        indicator filename
        element_defaults query_type languages
        localize_class submitted query input _auto_fieldset
        _elements _processed_params _valid_names /
);

__PACKAGE__->mk_inherited_accessors(
    qw/ auto_id auto_label auto_error_class auto_error_message
    auto_constraint_class /
);

*elements    = \&element;
*constraints = \&constraint;
*filters     = \&filter;
*deflators   = \&deflator;
*inflators   = \&inflator;
*loc         = \&localize;

our $VERSION = '0.00_01';

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
        auto_error_message  => 'form_%t_error',
    );

    $self->populate( \%defaults );

    $self->populate( \%attrs );

    return $self;
}

sub auto_fieldset {
    my $self = shift;
    
    return $self->_auto_fieldset if !@_;
    
    my %opts = ref $_[0] ? %{$_[0]} : ();
    
    $opts{type} = 'fieldset';
    
    $self->element( \%opts );
    
    $self->_auto_fieldset(1);
    
    return $self;
}

sub localize_object {
    my $self = shift;

    if (@_) {
        $self->{localize_object} = shift;

        return $self;
    }

    if ( !defined $self->{localize_object} ) {
        my $class = $self->localize_class;

        require_class($class);

        $self->{localize_object} = $class->get_handle( @{ $self->languages } );
    }

    return $self->{localize_object};
}

sub localize {
    my $self = shift;

    return $self->localize_object->localize(@_);
}

sub process {
    my $self = shift;

    $self->input(             {} );
    $self->_processed_params( {} );
    $self->_valid_names(      [] );
    $self->delete_errors;

    my $query;
    if (@_) {
        $query = shift;
        $self->query($query);
    }
    else {
        $query = $self->query;
    }
    my $submitted;
    my @params;

    if ( defined $query ) {
        $query = HTML::FormFu::FakeQuery->new($query)
            if !blessed($query);

        eval { @params = $query->param };
        croak "Invalid query object: $@" if $@;

        $submitted = $self->_submitted($query);
    }
    
    $self->submitted( $submitted );
    
    return if !$submitted;

    my %params;

    for my $param ( $query->param ) {

        # don't allow names without a matching field
        next unless $self->get_field($param);

        my @values = $query->param($param);
        $params{$param} = @values > 1 ? \@values : $values[0];
    }
        ### constraints
        #    my $render = $constraint->render_errors;
        #    my @render =
        #          ref $render     ? @{$render}
        #        : defined $render ? $render
        #        :                   ();
        #        $result->no_render(1)
        #            if @render && !grep { $name eq $_ } @render;
    
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
                grep { defined $_->name } @{ $self->get_fields }
        );

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
    
    $self->_filter_input;
    
    $self->_constrain_input;
    
    $self->_inflate_input;
    
    $self->_build_valid_names;
    
    $self->_build_file_headers;

    return;
}

sub _build_params {
    my ($self) = @_;

    my $input  = $self->input;
    my $fields = $self->get_fields;
    my %params;
    
    for my $field (@$fields) {
        my $name = $field->name;
        next if !defined $name;

        my $input = exists $input->{$name} ? $input->{$name} : undef;
        
        $input = dclone( $input )
            if ref $input eq 'ARRAY';
        
        $params{$name} = $input;
    }

    $self->_processed_params( \%params );
    
    return;
}

sub _constrain_input {
    my ($self) = @_;
    
    my $params = $self->_processed_params;

    for my $constraint ( map { @{ $_->get_constraints } } @{ $self->_elements } )
    {
        my @results = $constraint->process( $params );
        for my $result (@results) {
            $result->parent( $constraint->parent ) if !$result->parent;
            $result->constraint( $constraint )     if !$result->constraint;
            
            $result->parent->add_error( $result );
        }
    }
    
    return;
}

sub _filter_input {
    my ($self) = @_;

    for my $filter ( map { @{ $_->get_filters } } @{ $self->_elements } ) {
        $filter->process( $self, $self->_processed_params );
    }
    
    return;
}

sub _inflate_input {
    my ($self) = @_;

    for my $name ( keys %{ $self->_processed_params } ) {
        next if $self->has_errors($name);

        my $value = $self->_processed_params->{$name};

        for my $inflator ( map { @{ $_->get_inflators( { name => $name } ) } }
            @{ $self->_elements } )
        {
            $value = $inflator->process($value);
        }
        $self->_processed_params->{$name} = $value;
    }

    return;
}

sub _build_valid_names {
    my ($self) = @_;

    my @errors = $self->has_errors;
    my @names  = keys %{ $self->input };

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

sub _build_file_headers {
    my ($self) = @_;

    my $files = $self->get_fields( { type => 'file' } );

    if ($files) {
        my $class = $self->query_type;
        if ( $class !~ /^\+/ ) {
            $class = "HTML::FormFu::QueryType::$class";
        }
        require_class($class);

        for my $file (@$files) {
            my $header = $class->new( {
                    query => $self->query,
                    name  => $file->name,
                } );
            $file->headers( $header->headers );
        }
    }

    return;
}

sub submitted_and_valid {
    my ($self) = @_;
    
    return $self->submitted && !$self->has_errors;
}

sub params {
    my ($self) = @_;

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
    my $self  = shift;
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

    my @names = map { $_->name }
        grep { @{ $_->get_errors } }
        grep { defined $_->name }
        @{ $self->get_fields };

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
            _elements           => [ map { $_->render } @{ $self->_elements } ],
            parent              => $self,
        } );

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

    return join "", map { $_->render } 
        @{ $self->get_fields( { type => 'hidden' } ) };
}

1;

__END__

=head1 NAME

HTML::FormFu - HTML Form Creation, Rendering and Validation Framework

=head1 SYNOPSIS

    use HTML::FormFu;

    my $form = HTML::FormFu->new;
    
    $form->load_config_file('form.yml');

    $form->process( $cgi_query );

    if ( $form->submitted_and_valid ) {
        my $params = $result->params;
        my $person = $people->find( $params->{id} );
        
        $person->update(
            age  => $params->{age},
            name => $params->{name},
        );
        
        $template->param( updated => 1 );
    }
    else {
        $template->param( form => $form );
    }

You can use any templating system, or none, the L</render> method is 
automatically called when the <code>$form</code> is used as a string.

Here's an example of a config file to set up a basic login form (all examples 
here are L<YAML>, but you can use any format supported by L<Config::Any>).

    ---
    action: /login
    auto_fieldset: 1
    elements:
      - type: text
        name: email
        label: Email
        constraints: [Required, Email]
      - type: password
        name: pass
        label: Password
        constraints:
          - type: Length
            min: 6
      - type: submit
        name: submit

And here's what the rendered xhtml would look like (with indentation added 
manually).

    <form action="/login" method="post">
      <fieldset>
        <span class="text label">
          <label>Email</label>
          <input name="email" type="text" />
        </span>
        <span class="password label">
          <label>Password</label>
          <input name="pass" type="password" />
        </span>
        <span class="submit">
          <input name="submit" type="submit" />
        </span>
      </fieldset>
    </form>

=head1 DESCRIPTION

L<HTML::FormFu> is a HTML form framework which aims to be as easy as 
possible to use for basic web forms, but with the power and flexibility to 
do anything else you want to do, as long as it involves forms.

You can configure almost any part of L<HTML::FormFu's|HTML::FormFu> 
behaviour and output. By default L<HTML::FormFu> renders XHTML 1.0 
strict-complient markup, with no unnecessary tags, but with sufficient CSS 
class attributes to allow for a wide-range of output styles to be generated 
by changing only the CSS.

This documentation follows the convention that method arguments surrounded 
by square brackets C<[]> are I<optional>, and all other arguments are 
required.

=head1 METHODS

=head2 new

Arguments: [\%options]

Return Value: $form

Create a new HTML::FormFu object.

Any method which can be called on the <HTML::FormFu> object may instead be 
passed as an argument to L</new>.

    my $form = HTML::FormFu->new({
        action        => '/search',
        method        => 'GET',
        auto_fieldset => 1,
    });

All of the following methods can either be called on your <code>$form</code> 
object, or as an option in your config file. Argument lists are appropriate 
to both, but examples will mainly be shown in L<YAML> config syntax.

=head1 VISUAL ELEMENTS

=head2 element

=head2 elements

Arguments: $type

Arguments: \%options

Return Value: $element

Arguments: \@arrayref_of_type_values_or_option_hashrefs

Return Value: @elements

Adds a new element to the form. See L<HTML::FormFu::Element> for a list of 
core elements.

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

=head2 constraint

=head2 constraints

Arguments: $type

Arguments: \%options

Return Value: $constraint

Arguments: \@arrayref_of_type_values_or_option_hashrefs

Return Value: @constraint

B<!!!> L</constraints()> will soon be changed, see 
L<http://lists.rawmode.org/pipermail/html-widget/2007-March/000479.html>

See L<HTML::FormFu::Constraint> for a list of core constraints.

L</constraint> is an alias for L</constraints>.

=head2 filter

=head2 filters

Arguments: $type

Arguments: \%options

Return Value: $filter

Arguments: \@arrayref_of_type_values_or_option_hashrefs

Return Value: @filter

B<!!!> L</filters()> will soon be changed to run I<before> constraints, see 
L<http://lists.rawmode.org/pipermail/html-widget/2007-March/000479.html>

If you provide a C<name> or C<names> value, the filter will be added to 
just that named field.
If you do not provide a C<name> or C<names> value, the filter will be added 
to all L<fields|HTML::FormFu::Element::field> already attached to the form. 

If you want to load a filter in a namespace other than 
C<HTML::FormFu::Filter::>, you can use a fully qualified package-name by 
prefixing it with C<+>.

    ---
    elements:
      - foo
      - bar
    filters:
      - type: +MyApp::CustomFilter
        name: foo

See L<HTML::FormFu::Filter> for a list of core filters.

L</filter> is an alias for L</filters>.

=head1 ATTRIBUTES

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

=head1 ATTRIBUTE SHORTCUTS

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

=head1 OPTIONS

These options affect the behaviour of L<HTML::FormFu>.

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
      - type: text
        name: foo
      - type: text
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
      - type: text
        name: foo
      - type: text
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
      - type: text
        name: foo
      - type: text
        name: bar
      - type: fieldset
      - type: text
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

=head1 QUERYING THE FORM

=head2 get_fields

Arguments: %options

Arguments: \%options

Return Value: \@elements

    my $fields = $form->get_fields;

Returns all form-field type elements in the form (specifically, all elements 
which have a true L<HTML::FormFu::Element/is_field> value.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_fields({
        name => 'foo',
        type => 'radio',
    });

=head2 get_field

Arguments: %options

Arguments: \%options

Return Value: $element

    my $field = $form->get_field;

Accepts the same arguments as L</get_fields>, but only returns the first 
form-field found.

=head2 get_elements

Arguments: %options

Arguments: \%options

Return Value: \@elements

    my $elements = $form->get_elements;

Returns all top-level (not recursive) elements in the form.

Accepts both C<name> and C<type> arguments to narrow the returned results.

    $form->get_elements({
        name => 'foo',
        type => 'radio',
    });

See L</get_all_elements> for a recursive version.

=head2 get_element

Arguments: %options

Arguments: \%options

Return Value: $element

    my $element = $form->get_element;

Accepts the same arguments as L</get_elements>, but only returns the first 
element found.

=head2 get_filters

Arguments: %options

Arguments: \%options

Return Value: \@filters

    my $filters = $form->get_filters;

Returns all filters from all form-fields.

Accepts a C<type> argument to narrow the returned results.

    $form->get_filters({
        type => 'callback',
    });

=head2 get_filter

Arguments: %options

Arguments: \%options

Return Value: $filter

    my $filter = $form->get_filter;

Accepts the same arguments as L</get_filters>, but only returns the first 
filter found.

=head2 get_constraints

Arguments: %options

Arguments: \%options

Return Value: \@constraints

    my $constraints = $form->get_constraints;

Returns all constraints from all form-fields.

Accepts a C<type> argument to narrow the returned results.

    $form->get_constraints({
        type => 'callback',
    });

=head2 get_constraint

Arguments: %options

Arguments: \%options

Return Value: $constraint

    my $constraint = $form->get_constraint;

Accepts the same arguments as L</get_constraints>, but only returns the 
first constraint found.

=head1 CUSTOMISATION

=head2 filename

Change the template filename used for the form.

Default Value: "form"

=head2 render_class

Set the classname used to create a form render object. If set, the values of 
L</render_class_prefix> and L</render_class_suffix> are ignored.

Default Value: none

=head2 render_class_prefix

Set the prefix used to generate the classname of the form render object and 
all Element render objects.

Default Value: "HTML::FormFu::Render"

=head2 render_class_suffix

Set the suffix used to generate the classname of the form render object.

Default Value: "Form"

=head2 render_class_args

Arguments: \%constructor_arguments

Accepts a hash-ref of arguments passed to the render object constructor for 
the form and all elements.

The default render class (L<HTML::FormFu::Render::Base>) passes these 
arguments to the L<TT|Template> constructor.

The keys C<RELATIVE> and C<RECURSION> are overridden to always be true, as 
these are a basic requirement for the L<Template> engine.

The default value of C<INCLUDE_PATH> is C<root>. This should generally be 
overridden to point to the location of the HTML::FormFu template files on 
your local system. 

=head1 FREQUENTLY ASKED QUESTIONS (FAQ)

=head2 How do I add an onSubmit handler to the form?

    ---
    attributes_xml: { onsubmit: $javascript }

See L<HTML::FormFu/attributes>.

=head2 How do I add an onChange handler to a form field?

    ---
    elements:
      - type: text
        attributes_xml: { onchange: $javascript }

See L<HTML::FormFu::Element/attributes>.

=head2 Element X does not have an accessor for Y!

You can add any arbitrary attributes with 
L<HTML::FormFu::Element/attributes>.

=head2 How can I add a tag which isn't included?

You can use the L<HTML::FormFu::Element::Block> element, and set
the L<tag|HTML::FormFu::Element::Block/tag> to the tag type you want.

    ---
    auto_fieldset: 1
    elements:
      - type: block
        tag: span

=head1 SUPPORT

Mailing list:

L<http://lists.rawmode.org/cgi-bin/mailman/listinfo/html-widget>

=head1 SUBVERSION REPOSITORY

The publicly viewable subversion code repository is at 
L<https://html-formfu.googlecode.com/svn/trunk/HTML-FormFu>.

=head1 SEE ALSO

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget>, by Sebastian Riedel, 
C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
