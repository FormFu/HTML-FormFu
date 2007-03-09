package HTML::FormFu;
use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_inherited_accessors );
use HTML::FormFu::Attribute qw/ mk_attrs mk_attr_accessors /;
use HTML::FormFu::Constraint;
use HTML::FormFu::Error;
use HTML::FormFu::FakeQuery;
use HTML::FormFu::Filter;
use HTML::FormFu::Inflator;
use HTML::FormFu::ObjectUtil
    qw/ element constraint filter deflator inflator
    get_elements get_element get_all_elements get_fields get_field 
    get_constraints get_constraint get_filters get_filter  
    get_deflators get_deflator get_inflators get_inflator
    populate localize load_config_file insert_after form
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
        _elements _errors _processed_params _valid_names /
);

__PACKAGE__->mk_inherited_accessors(qw/ auto_id auto_label /);

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
        _errors             => {},
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

sub process {
    my $self = shift;

    $self->input(             {} );
    $self->_processed_params( {} );
    $self->_errors(           {} );
    $self->_valid_names(      [] );

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

    $self->_constrain_input;
    
    $self->_re_process_input;
    
    $self->_build_file_headers;

    return;
}

sub _re_process_input {
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

    $self->_filter_input;
    $self->_inflate_input;

    $self->_build_valid_names;
    
    return;
}

sub _constrain_input {
    my ($self) = @_;
    
    my $params = $self->input;

    my %errors;
    for my $constraint ( map { @{ $_->get_constraints } } @{ $self->_elements } )
    {
        my $results = $constraint->process( $self, $params ) || [];
        for my $result (@$results) {
            push @{ $errors{ $result->name } }, $result;
        }
    }
    $self->_errors( \%errors );
    
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

    my @names = keys %{ $self->_errors };

    if (@_) {
        my $name = shift;
        return 1 if grep {/\Q$name/} @names;
        return;
    }

    # return list of names with errors, if no $name arg
    return @names;
}

sub errors {
    my $self   = shift;
    my %args   = _parse_args(@_);
    my %errors = %{ $self->_errors };

    return if exists $args{name} && !exists $errors{ $args{name} };

    my @names = exists $args{name} ? $args{name} : keys %errors;
    my @errors;
    for my $n (@names) {
        for my $error ( @{ $errors{$n} } ) {
            next if exists $args{type} && $error->type ne $args{type};
            push @errors, $error;
        }
    }

    # empty list because a ref to an empty array is not false!
    return @errors ? \@errors : ();
}

sub add_valid {
    my ( $self, $key, $value ) = @_;

    croak 'add_valid requires arguments ($key, $value)' unless @_ == 3;

    $self->input->{$key} = $value;

    $self->_re_process_input;

    return $value;
}

sub add_error {
    my $self = shift;
    my %args = _parse_args(@_);

    croak "name required" unless defined $args{name};

    my %new;
    for (qw/ name type class /) {
        $new{$_} = delete $args{$_} if exists $args{$_};
    }

    my $error = HTML::FormFu::Error->new( \%new );

    $error->parent( $self->get_field( $error->name ) );
    weaken( $error->{parent} );

    {
        my ( $method, $value ) = %args;
        if ( !defined $value ) {
            $method = 'message_loc';
            $value  = 'form_default_error';
        }
        $error->$method($value);
    }
    
    push @{ $self->_errors->{ $error->name } }, $error;

    $self->_re_process_input;

    return $error;
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

    # Create a form
    my $form = HTML::FormFu->new;
    
    # Load some default settings from a config file
    $form->load_config_file('form_defaults.yml');

    # Add a fieldset to contain the elements
    my $fs = $form->element('Fieldset')
        ->legend('User Details');

    # Add some elements to the fieldset
    $fs->element( Hidden => 'id' )
        ->value( $person->id )
        ->constraint('Integer');
    
    $fs->element( Text => 'age' )
        ->label('Age')
        ->size(3)
        ->comment('(Required)')
        ->value( $person->age )
        ->constraint('Integer')
        ->filter('Whitespace');
    
    # Using an alternative syntax
    $fs->element(
        Text => 'name',
        {
            label      => 'Name',
            size       => 60,
            comment    => '(Required)',
            value      => $person->name,
        });
    
    $fs->element('Submit');

    # Add some constraints to the current fields
    $form->constrain_all('Required');
    $form->constrain_all('SingleValue');

    # Field indicating the form's been submitted
    $form->indicator('id');

    # Create a result object
    my $result = $form->result( CGI->new );

    if ( $result->submitted && ! $result->has_errors ) {
        my $params = $result->params;
        my $person = $people->find( $params->{id} );
        
        $person->update(
            age  => $params->{age},
            name => $params->{name},
        );
        
        redirect('updated!');
    }


    # Render the form in a TT template
    [% result %]


=head1 DESCRIPTION

Create reusable HTML forms. Optionally, just use the validation 
capabilities, or just the form rendering.

The design is based on L<HTML::Widget>, and draws from 
L<Data::FormValidator> and L<FormValidator::Simple>.
Functionality similar to that of L<HTML::FillInForm> is built-in.

This documentation follows the convention that method arguments surrounded 
by square brackets C<[]> are I<optional>, and all other arguments are 
required.

=head1 METHODS

=head2 new

Arguments: [\%options]

Return Value: $form

Create a new HTML::FormFu object.

Any method which can be called on the <HTML::FormFu> object may instead be 
passed as an argument to L</new>. This includes all L<"ATTRIBUTES">, 
L<"ATTRIBUTE SHORTCUTS"> and L</"OPTIONS"> methods.

    my $form = HTML::FormFu->new({
        action     => 'program.cgi',
        method     => 'GET',
        attributes => \%attrs,
    });

All options passed in this way will be called as methods on the 
L<HTML::FormFu> object. Unknown options will throw an exception.

=head1 BUILDING THE FORM

=head2 element

Arguments: $type, [$name], [\%options]

Return Value: $element

Add a new element to the form. 
The returned element object can be used to set further attributes, see the 
individual element classes for the methods specific to each.

If you want to load an element from a namespace other than 
C<HTML::FormFu::Element::>, you can use a fully qualified package-name by 
prefixing it with a unary plus (C<+>).

    $form->element( "+Fully::Qualified::PackageName", $name );

See L<HTML::FormFu::Element> for a list of core elements.

=head2 constraint

Arguments: $type, @field_names

Return Value: $constraint

    $form->constraint( Integer => 'age' );
    
    $form->constraint( Required => map {$_->name} $form->get_fields );

Associate a constraint with one or more elements. 
When process() is called on the FormFu object, with a $query object, 
the parameters of the query are checked against the specified constraints. 
The L<HTML::FormFu::Constraint> object is returned to allow setting of 
further attributes to be set. The string 'Not_' can be prepended to each 
type name to negate the effects. Thus checking for a non-integer becomes 
'Not_Integer'.

If you want to load a constraint in a namespace other than 
C<HTML::FormFu::Constraint::>, you can use a fully qualified package-name 
by prefixing it with a unary plus (C<+>).

    $form->constraint( "+Fully::Qualified::PackageName", @names );

Constraint checking is done after all L<filters|HTML::FormFu::Filter> have 
been applied.

See L<HTML::FormFu::Constraint> for a list of available constraints.

=head2 filter

Arguments: $type, @field_names

Return Value: $filter

    $form->filter( WhiteSpace => 'postcode' );
    
    $form->filter( TrimEdges => map {$_->name} $form->get_fields );

Add a filter. Like constraints, filters can be applied to one or more elements.
These are applied to actually change the contents of the fields, supplied by
the user before checking the constraints. It only makes sense to apply filters
to fields that can contain text - Password, Textfield, Textarea, Upload.

If you want to load a filter in a namespace other than 
C<HTML::FormFu::Filter::>, you can use a fully qualified package-name by 
prefixing it with a unary plus (C<+>).

    $form->filter( "+Fully::Qualified::PackageName", @names );

See L<HTML::FormFu::Filter> for a list of available filters.

=head1 RENDERING AND VALIDATION

=head2 result

Arguments: [$query]

Return Value: $result

    my $result = $form( $query );

Returns a L<HTML::FormFu::Result::Form> object. If passed a C<$query> it will 
run filters and validation on the parameters.

The L<$result> object can then be used to check valid input or output the 
form in XHTML

=head1 ATTRIBUTES

All attributes are passed to L<HTML::FormFu::Result>, and added to the 
rendered form's start tag.

=head2 attributes

=head2 attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

Return Value: \%attributes

Accepts either a list of key/value pairs, or a hash-ref.

    $form->attributes( $key => $value );
    $form->attributes( { $key => $value } );

Returns the C<$form> object, to allow method chaining.

If no arguments are passed, the attributes hash-ref is returned.

This allows the entire attributes hash to be deleted with the following 
idiom: C<< %{ $form->attributes } = (); >>

L</attrs> is an alias for L</attributes>.

=head2 attributes_xml

=head2 attrs_xml

Arguments and Return Value: same as L<"/attributes">

Provides the same functionality as L<"/attributes">, but values are 
automatically passed as L<HTML::FormFu::Literal> objects, to ensure that 
special XHTML characters are not encoded in the rendered output.

L</attrs_xml> is an alias for L</attributes_xml>.

=head2 add_attributes

=head2 add_attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

Accepts either a list of key/value pairs, or a hash-ref.

    $form->add_attributes( $key => $value );
    $form->add_attributes( { $key => $value } );

Returns the C<$form> object, to allow method chaining.

All values are appended to existing values, using 
L<HTML::FormFu::Util/append_xml_attribute>.

L</add_attrs> is an alias for L</add_attributes>.

=head2 add_attributes_xml

=head2 add_attrs_xml

Arguments and Return Value: same as L<"/add_attributes">

Provides the same functionality as L<"/add_attributes">, but values are 
automatically passed as L<HTML::FormFu::Literal> objects, to ensure that 
special XHTML characters are not encoded in the rendered output.

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

Get/Set the action associated with the form. The default is no action, 
which causes most browsers to submit to the current URI.

Default Value: ""

=head2 enctype

Arguments: [$enctype]

Return Value: $enctype

Set/Get the encoding type of the form. Valid values are 
C<application/x-www-form-urlencoded> and C<multipart/form-data>.

If the form contains a File element, the enctype is automatically set to
C<multipart/form-data>.

=head2 method

Arguments: [$method]

Return Value: $method

Set/Get the method used to submit the form. Can be set to either "post" or
"get".

Default Value: "post"

=head1 OPTIONS

These options affect the behaviour of the C<$form|HTML::FormFu> and 
C<$result|HTML::FormFu::Result::Form> objects.

=head2 indicator

Arguments: [$field_name]

Arguments: [\&coderef]

The indicator is used by L<HTML::FormFu::Result::Form/submitted> to determine 
whether the form has been submitted.

=head1 QUERYING THE FORM

=head2 get_fields

Arguments: [%options]

Return Value: @elements

    my @fields = $form->get_fields;

Similar to L<get_elements>, but only returns elements which inherit from 
L<HTML::FormFu::Element::FormField>.

Exactly equivalent to:

    my @fields = $form->get_elements( type => 'FormField' );

=head2 get_field

Arguments: [%options]

Return Value: $element

    my $field = $form->get_field;

Accepts the same arguments as L<get_fields>, but only returns a single 
element if there are multiple elements with the same name.

=head2 get_elements

Arguments: [%options]

Return Value: @elements

    my @elements = $form->get_elements;
    
    my @elements = $form->get_elements( type => 'Textfield' );
    
    my @elements = $form->get_elements( name => 'username' );

Returns a list of all elements added to the form.

If a 'type' argument is given, only returns the elements of that type.

If a 'name' argument is given, only returns the elements with that name.

Note: To reflect the different typical usage between a C<$form> object and 
a C<$result> object, C<< $form->get_elements >> always returns a list, 
whereas C<< $result->elements >> always returns an array-ref so that it 
may be more easily used in html templates.

=head2 get_element

Arguments: [%options]

Return Value: $element

    my $element = $form->get_element;

Accepts the same arguments as L<get_elements>, but only returns the first 
element in the list of results.

=head2 get_filters

Arguments: [%options]

Return Value: @filters

    my @filters = $form->get_filters;
    
    my @filters = $form->get_filters( type => 'Integer' );

Returns a list of all filters added to the FormFu.

If a 'type' argument is given, only returns the filters of that type.

=head2 get_filter

Arguments: %options

Return Value: $filter

    my @filters = $form->get_filter;
    
    my @filters = $form->get_filter( type => 'Integer' );

Accepts the same arguments as L</get_filters>, but only returns the first 
element in the list of results.

Accepts the same arguments as L</get_filters>.

=head2 get_constraints

Arguments: [%options]

Return Value: @constraints

    my @constraints = $form->get_constraints;
    
    my @constraints = $form->get_constraints( type => 'Integer' );

Returns a list of all constraints added to the FormFu.

If a 'type' argument is given, only returns the constraints of that type.

=head2 get_constraint

Arguments: [%options]

Return Value: $constraint

    my $constraint = $form->get_constraint;
    
    my $constraint = $form->get_constraint( type => 'Integer' );

Accepts the same arguments as L</get_constraints>, but only returns a single 
element if there are multiple elements with the same name.

=head1 CUSTOMISATION

=head2 filename

Change the template filename used for the form.

Default Value: "form"

=head2 result_class

Set the classname used to create a form result object. If set, the values of 
L</result_class_prefix> and L</result_class_suffix> are ignored.

Default Value: none

=head2 result_class_prefix

Set the prefix used to generate the classname of the form result object and 
all Element result objects.

Default Value: "HTML::FormFu::Result"

=head2 result_class_suffix

Set the suffix used to generate the classname of the form result object.

Default Value: "Form"

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

    $form->attributes_xml( onsubmit => $javascript );

See L<HTML::FormFu/attributes>.

=head2 How do I add an onChange handler to a form field?

    $element->attributes_xml( onchange => $javascript );

See L<HTML::FormFu::Element/attributes>.

=head2 Element X does not have an accessor for Y!

You can add any arbitrary attributes with 
L<HTML::FormFu::Element/attributes>.

=head2 How can I add a tag which isn't included?

You can use the L<HTML::FormFu::Element::Block> element, and set
the L<type|HTML::FormFu::Element::Block/type> to the tag type you want.

    $fieldset->element('Block')
        ->type('span')
        ->class('my_message')
        ->element('Src')
            ->content('Hi!');
    
    # will render as
    <span class="my_message">Hi!</span>

=head1 SUPPORT

Mailing list:

L<http://lists.rawmode.org/cgi-bin/mailman/listinfo/html-widget>

=head1 SUBVERSION REPOSITORY

The publicly viewable subversion code repository is at 
L<TODO>.

=head1 SEE ALSO

L<HTML::FormFu::Element>, L<HTML::FormFu::Constraint>, 
L<HTML::FormFu::Filter>, L<HTML::FormFu::Result::Form>.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget>, by Sebastian Riedel, 
C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
