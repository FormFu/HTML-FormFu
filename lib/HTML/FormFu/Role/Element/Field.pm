package HTML::FormFu::Role::Element::Field;
use Moose::Role;
use MooseX::Aliases;

with 'HTML::FormFu::Role::ContainsElementsSharedWithField',
     'HTML::FormFu::Role::NestedHashUtils';

use HTML::FormFu::Attribute qw(
    mk_attrs
    mk_output_accessors
    mk_inherited_accessors
);
use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw(
    _parse_args                 append_xml_attribute
    xml_escape                  require_class
    process_attrs               _filter_components
);
use Class::MOP::Method;
use Clone ();
use List::MoreUtils qw( uniq );
use Carp qw( croak );

__PACKAGE__->mk_attrs( qw(
        comment_attributes
        container_attributes
        label_attributes
) );

has _constraints         => ( is => 'rw', traits => ['Chained'] );
has _filters             => ( is => 'rw', traits => ['Chained'] );
has _inflators           => ( is => 'rw', traits => ['Chained'] );
has _deflators           => ( is => 'rw', traits => ['Chained'] );
has _validators          => ( is => 'rw', traits => ['Chained'] );
has _transformers        => ( is => 'rw', traits => ['Chained'] );
has _plugins             => ( is => 'rw', traits => ['Chained'] );
has _errors              => ( is => 'rw', traits => ['Chained'] );
has container_tag        => ( is => 'rw', traits => ['Chained'] );
has field_filename       => ( is => 'rw', traits => ['Chained'] );
has label_filename       => ( is => 'rw', traits => ['Chained'] );
has label_tag            => ( is => 'rw', traits => ['Chained'] );
has retain_default       => ( is => 'rw', traits => ['Chained'] );
has force_default        => ( is => 'rw', traits => ['Chained'] );
has javascript           => ( is => 'rw', traits => ['Chained'] );
has non_param            => ( is => 'rw', traits => ['Chained'] );
has reverse_single       => ( is => 'rw', traits => ['Chained'] );
has reverse_multi        => ( is => 'rw', traits => ['Chained'] );
has multi_value          => ( is => 'rw', traits => ['Chained'] );
has original_name        => ( is => 'rw', traits => ['Chained'] );
has original_nested_name => ( is => 'rw', traits => ['Chained'] );

__PACKAGE__->mk_output_accessors(qw( comment label value placeholder ));

__PACKAGE__->mk_inherited_accessors( qw(
        auto_id                     auto_label
        auto_error_class            auto_error_message
        auto_constraint_class       auto_inflator_class
        auto_validator_class        auto_transformer_class
        render_processed_value      force_errors
        repeatable_count            default_empty_value
        locale
) );

alias( "default",     "value" );
alias( "default_xml", "value_xml" );
alias( "default_loc", "value_loc" );

after BUILD => sub {
    my $self = shift;

    $self->_constraints(  [] );
    $self->_filters(      [] );
    $self->_deflators(    [] );
    $self->_inflators(    [] );
    $self->_validators(   [] );
    $self->_transformers( [] );
    $self->_plugins(      [] );
    $self->_errors(       [] );
    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->label_attributes(     {} );
    $self->label_filename('label');
    $self->label_tag('label');
    $self->container_tag('div');
    $self->is_field(1);

    return;
};

sub nested {
    my ($self) = @_;

    croak 'cannot set nested' if @_ > 1;

    if ( defined $self->name ) {
        my $parent = $self;

        while ( defined( $parent = $parent->parent ) ) {

            if ( $parent->can('is_field') && $parent->is_field ) {
                return 1 if defined $parent->name;
            }
            else {
                return 1 if defined $parent->nested_name;
            }
        }
    }

    return;
}

sub nested_name {
    my ($self) = @_;

    croak 'cannot set nested_name' if @_ > 1;

    return if !defined $self->name;

    my @names = $self->nested_names;

    if ( $self->form->nested_subscript ) {
        my $name = shift @names;
        map { $name .= "[$_]" } @names;
# TODO - Mario Minati 19.05.2009
# Does this (name formatted as '[name]') collide with FF::Model::HashRef as
# it uses /_\d/ to parse repeatable names?
        return $name;
    }
    else {
        return join ".", @names;
    }
}


sub nested_names {
    my ($self) = @_;

    croak 'cannot set nested_names' if @_ > 1;

    if ( defined( my $name = $self->name ) ) {
        my @names;
        my $parent = $self;

        # micro optimization! this method's called a lot, so access
        # parent hashkey directly, instead of calling parent()
        while ( defined( $parent = $parent->{parent} ) ) {

            if ( $parent->can('is_field') && $parent->is_field ) {
                # handling Field
                push @names, $parent->name
                    if defined $parent->name;
            }
            elsif ( $parent->can('is_repeatable') && $parent->is_repeatable ) {
                # handling Repeatable
                # ignore Repeatables nested_name attribute as it is provided
                # by the childrens Block elements
            }
            else {
                # handling 'not Field' and 'not Repeatable'
                push @names, $parent->nested_name
                    if defined $parent->nested_name;
            }
        }

        if (@names) {
            return reverse $name, @names;
        }
    }

    return ( $self->name );
}

sub build_original_nested_name {
    my ($self) = @_;

    croak 'cannot set build_original_nested_name' if @_ > 1;

    return if !defined $self->name;

    my @names = $self->build_original_nested_names;

    if ( $self->form->nested_subscript ) {
        my $name = shift @names;
        map { $name .= "[$_]" } @names;
# TODO - Mario Minati 19.05.2009
# Does this (name formatted as '[name]') collide with FF::Model::HashRef as
# it uses /_\d/ to parse repeatable names?
        return $name;
    }
    else {
        return join ".", @names;
    }
}

sub build_original_nested_names {
    my ($self) = @_;

    croak 'cannot set build_original_nested_names' if @_ > 1;

# TODO - Mario Minati 19.05.2009
# Maybe we have to use original_name instead of name.
# Yet there is no testcase, which is currently failing. 

    if ( defined( my $name = $self->name ) ) {
        my @names;
        my $parent = $self;

        # micro optimization! this method's called a lot, so access
        # parent hashkey directly, instead of calling parent()
        while ( defined( $parent = $parent->{parent} ) ) {

            if ( $parent->can('is_field') && $parent->is_field ) {
                # handling Field
                if (defined $parent->original_name) {
                    push @names, $parent->original_name;
                }
                elsif (defined $parent->name) {
                    push @names, $parent->name;
                }
            }
            elsif ( $parent->can('is_repeatable') && $parent->is_repeatable ) {
                # handling Repeatable
# TODO - Mario Minati 19.05.2009
# Do we have to take care of chains of Repeatable elements, if the Block
# elements have already been created for the outer Repeatable elements to
# avoid 'outer.outer_1.inner'
# Yet there is no failing testcase. All testcases in FF and FF::Model::DBIC
# which have nested repeatable elements are passing currently.
                push @names, $parent->original_nested_name
                    if defined $parent->original_nested_name;
            }
            else {
                # handling 'not Field' and 'not Repeatable'
                if ($parent->can('original_nested_name') && defined $parent->original_nested_name) {
                    push @names, $parent->original_nested_name;
                }
                elsif (defined $parent->nested_name) {
                    push @names, $parent->nested_name
                }
            }
        }

        if (@names) {
            return reverse $name, @names;
        }
    }

    return ( $self->name );
}

sub nested_base {
    my ($self) = @_;

    croak 'cannot set nested_base' if @_ > 1;

    my $parent = $self;

    while ( defined( $parent = $parent->parent ) ) {

        return $parent->nested_name if defined $parent->nested_name;
    }
}

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_deflators };

    return _filter_components( \%args, \@x );
}

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_filters };

    return _filter_components( \%args, \@x );
}

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_constraints };

    return _filter_components( \%args, \@x );
}

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_inflators };

    return _filter_components( \%args, \@x );
}

sub get_validators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_validators };

    return _filter_components( \%args, \@x );
}

sub get_transformers {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_transformers };

    return _filter_components( \%args, \@x );
}

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_errors };

    _filter_components( \%args, \@x );

    if ( !$args{forced} ) {
        @x = grep { !$_->forced } @x;
    }

    return \@x;
}

sub clear_errors {
    my ($self) = @_;

    $self->_errors( [] );

    return;
}

after pre_process => sub {
    my $self = shift;

    for my $plugin ( @{ $self->_plugins } ) {
        $plugin->pre_process;
    }

    return;
};

after process => sub {
    my $self = shift;

    for my $plugin ( @{ $self->_plugins } ) {
        $plugin->process;
    }

    return;
};

after post_process => sub {
    my $self = shift;

    for my $plugin ( @{ $self->_plugins } ) {
        $plugin->post_process;
    }

    return;
};

sub process_input {
    my ( $self, $input ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;
    my $original  = $self->value;
    my $name      = $self->nested_name;

    # set input to default value (defined before calling FormFu->process)
    if ( $submitted && $self->force_default && defined $default ) {
        $self->set_nested_hash_value( $input, $name, $default );
    }

    # checkbox, radio
    elsif ( $submitted && $self->force_default && $self->checked ) {

        # the checked attribute is set, so force input to be the original value
        $self->set_nested_hash_value( $input, $name, $original );
    }

    # checkbox, radio
    elsif ($submitted
        && $self->force_default
        && !defined $default
        && defined $original )
    {

    # default and value are not equal, so this element is not checked by default
        $self->set_nested_hash_value( $input, $name, undef );
    }

    return;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    if (  !defined $render->{attributes}{id}
        && defined $self->auto_id
        && length $self->auto_id )
    {
        my $form_name
            = defined $self->form->id
            ? $self->form->id
            : $EMPTY_STR;

        my $field_name
            = defined $render->{nested_name}
            ? $render->{nested_name}
            : $EMPTY_STR;

        my %string = (
            f => $form_name,
            n => $field_name,
        );

        my $id = $self->auto_id;
        $id =~ s/%([fn])/$string{$1}/g;

        if ( defined( my $count = $self->repeatable_count ) ) {
            $id =~ s/%r/$count/g;
        }

        $render->{attributes}{id} = $id;
    }

    return;
}

sub process_value {
    my ( $self, $value ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;

    my $new;

    if ($submitted) {
        if ( defined $value ) {
            $new = $value;
        }
        elsif ( defined $default ) {
            $new = $EMPTY_STR;
        }
    }
    else {
        $new = $default;
    }

    if (   $submitted
        && $self->retain_default
        && defined $new
        && $new eq $EMPTY_STR )
    {
        $new = $default;
    }

    # if the default value has been changed after FormFu->process has been
    # called we use it and set the value to that changed default again
    if (   $submitted
        && $self->force_default
        && defined $default
        && $new ne $default )
    {
        $new = $default;
    }

    return $new;
}

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig({
        nested_name          => xml_escape( $self->nested_name ),
        comment_attributes   => xml_escape( $self->comment_attributes ),
        container_attributes => xml_escape( $self->container_attributes ),
        label_attributes     => xml_escape( $self->label_attributes ),
        comment              => xml_escape( $self->comment ),
        label                => xml_escape( $self->label ),
        field_filename       => $self->field_filename,
        label_filename       => $self->label_filename,
        label_tag            => $self->label_tag,
        container_tag        => $self->container_tag,
        reverse_single       => $self->reverse_single,
        reverse_multi        => $self->reverse_multi,
        javascript           => $self->javascript,
        $args ? %$args : (),
    });

    $self->_render_container_class($render);
    $self->_render_comment_class($render);
    $self->_render_label($render);
    $self->_render_value($render);
    $self->_render_constraint_class($render);
    $self->_render_inflator_class($render);
    $self->_render_validator_class($render);
    $self->_render_transformer_class($render);
    $self->_render_error_class($render);

    return $render;
};

sub _render_label {
    my ( $self, $render ) = @_;

    if (  !defined $render->{label}
        && defined $self->auto_label
        && length $self->auto_label )
    {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
        );

        my $label = $self->auto_label;
        $label =~ s/%([fn])/$string{$1}/g;

        $render->{label} = $self->form->localize($label);
    }

    if ( defined $render->{label} ) {
        append_xml_attribute( $render->{container_attributes},
            'class', $self->label_tag );
    }

    # label "for" attribute
    if (   defined $render->{label}
        && defined $render->{attributes}{id}
        && !exists $render->{label_attributes}{for} )
    {
        $render->{label_attributes}{for} = $render->{attributes}{id};
    }

    return;
}

sub _render_comment_class {
    my ( $self, $render ) = @_;

    if ( defined $render->{comment} ) {
        append_xml_attribute( $render->{comment_attributes},
            'class', 'comment' );

        append_xml_attribute( $render->{container_attributes},
            'class', 'comment' );
    }

    return;
}

sub _render_value {
    my ( $self, $render ) = @_;

    my $form = $self->form;
    my $name = $self->nested_name;

    my $input;

    if (   $self->form->submitted
        && defined $name
        && $self->nested_hash_key_exists( $form->input, $name ) )
    {
        if ( $self->render_processed_value ) {
            $input
                = $self->get_nested_hash_value( $form->_processed_params, $name,
                );
        }
        else {
            $input = $self->get_nested_hash_value( $form->input, $name, );
        }
    }

    if ( ref $input eq 'ARRAY' ) {
        my $elems = $self->form->get_fields( $self->name );
        for ( 0 .. @$elems - 1 ) {
            if ( $self == $elems->[$_] ) {
                $input = $input->[$_];
            }
        }
    }

    my $value = $self->process_value($input);

    if ( !$self->form->submitted
        || ( $self->render_processed_value && defined $value ) )
    {
        for my $deflator ( @{ $self->_deflators } ) {
            $value = $deflator->process($value);
        }
    }

    # handle multiple values for the same name
    if ( ref $value eq 'ARRAY' && defined $self->name ) {
        my $max = $#$value;
        my $fields = $self->form->get_fields( name => $self->name );

        for my $i ( 0 .. $max ) {
            if ( defined $fields->[$i] && $fields->[$i] eq $self ) {
                $value = $value->[$i];
                last;
            }
        }
    }

    $render->{value} = xml_escape($value);

    return;
}

sub _render_container_class {
    my ( $self, $render ) = @_;

    my $type = $self->type;
    $type =~ s/:://g;

    append_xml_attribute( $render->{container_attributes}, 'class', lc($type),
    );

    return;
}

sub _render_constraint_class {
    my ( $self, $render ) = @_;

    my $auto_class = $self->auto_constraint_class;

    return if !defined $auto_class;

    for my $c ( @{ $self->_constraints } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );

        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;

        my $class = $auto_class;

        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class, );
    }

    return;
}

sub _render_inflator_class {
    my ( $self, $render ) = @_;

    my $auto_class = $self->auto_inflator_class;

    return if !defined $auto_class;

    for my $c ( @{ $self->_inflators } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );

        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;

        my $class = $auto_class;

        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class, );
    }

    return;
}

sub _render_validator_class {
    my ( $self, $render ) = @_;

    my $auto_class = $self->auto_validator_class;

    return if !defined $auto_class;

    for my $c ( @{ $self->_validators } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );

        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;

        my $class = $auto_class;

        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class, );
    }

    return;
}

sub _render_transformer_class {
    my ( $self, $render ) = @_;

    my $auto_class = $self->auto_transformer_class;

    return if !defined $auto_class;

    for my $c ( @{ $self->_transformers } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );

        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;

        my $class = $auto_class;

        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class, );
    }

    return;
}

sub _render_error_class {
    my ( $self, $render ) = @_;

    my @errors = @{ $self->get_errors( { forced => 1 } ) };

    if (@errors) {
        $render->{errors} = \@errors;

        append_xml_attribute( $render->{container_attributes},
            'class', 'error' );

        my @class = uniq map { $_->class } @errors;

        for my $class (@class) {
            append_xml_attribute( $render->{container_attributes},
                'class', $class, );
        }
    }

    return;
}

sub render_label {
    my ($self) = @_;

    return $self->tt( { filename => $self->{label_filename} } );
}

sub render_field {
    my ($self) = @_;

    return $self->tt( { filename => $self->{field_filename} } );
}

sub _string_field_start {
    my ( $self, $render ) = @_;

    # field wrapper template - start

    my $html = '';

    if ( defined $render->{container_tag} ) {
        $html .= sprintf '<%s%s>',
            $render->{container_tag},
            process_attrs( $render->{container_attributes} );
    }

    if ( defined $render->{label} && $render->{label_tag} eq 'legend' ) {
        $html .= sprintf "\n%s", $self->_string_label($render);
    }

    if ( $render->{errors} ) {
        for my $error ( @{ $render->{errors} } ) {
            $html .= sprintf qq{\n<span class="error_message %s">%s</span>},
                $error->class,
                $error->message,
                ;
        }
    }

    if ( defined $render->{label} && $render->{label_tag} ne 'legend' &&
         !$render->{reverse_single}) {
        $html .= sprintf "\n%s", $self->_string_label($render);
    }

    if ( defined $render->{container_tag} ) {
        $html .= "\n";
    }

    return $html;
}

sub _string_label {
    my ( $self, $render ) = @_;

    # label template

    my $html = sprintf "<%s%s>%s</%s>",
        $render->{label_tag},
        process_attrs( $render->{label_attributes} ),
        $render->{label},
        $render->{label_tag},
        ;

    return $html;
}

sub _string_field_end {
    my ( $self, $render ) = @_;

    # field wrapper template - end

    my $html = '';

    if ( defined $render->{label} && $render->{label_tag} ne 'legend' &&
         $render->{reverse_single} )
    {
        $html .= sprintf "\n%s", $self->_string_label($render);
    }

    if ( defined $render->{comment} ) {
        $html .= sprintf "\n<span%s>\n%s\n</span>",
            process_attrs( $render->{comment_attributes} ),
            $render->{comment},
            ;
    }

    if ( defined $render->{container_tag} ) {
        $html .= sprintf "\n</%s>", $render->{container_tag},;
    }

    if ( defined $render->{javascript} ) {
        $html .= sprintf qq{\n<script type="text/javascript">\n%s\n</script>},
            $render->{javascript},
            ;
    }

    return $html;
}

around clone => sub {
    my $orig = shift;
    my $self = shift;

    my $clone = $self->$orig(@_);

    for my $list ( qw(
        _filters _constraints _inflators _validators _transformers
        _deflators _errors _plugins )
        )
    {
        $clone->$list( [ map { $_->clone } @{ $self->$list } ] );

        map { $_->parent($clone) } @{ $clone->$list };
    }

    $clone->comment_attributes( Clone::clone( $self->comment_attributes ) );
    $clone->container_attributes( Clone::clone( $self->container_attributes ) );
    $clone->label_attributes( Clone::clone( $self->label_attributes ) );

    return $clone;
};

1;

__END__

=head1 NAME

HTML::FormFu::Element::_Field - base class for all form-field elements

=head1 DESCRIPTION

Base-class for all form-field elements.

=head1 METHODS

=head2 default

Set the form-field's default value.

=head2 default_xml

Arguments: $string

If you don't want the default value to be XML-escaped, use the 
L</default_xml> method instead of L</default>.

=head2 default_loc

Arguments: $localization_key

Set the default value using a L10N key.

=head2 value

For most fields, L</value> is an alias for L</default>.

For the L<HTML::FormFu::Element::Checkbox> and 
L<HTML::FormFu::Element::Radio> elements, L</value> sets what the value of 
the field will be if it is checked or selected. If the L</default> is the 
same as the L</value>, then the field will be checked or selected when 
rendered.

For the L<HTML::FormFu::Element::Radiogroup> and 
L<HTML::FormFu::Element::Select> elements, the L</value> is ignored: 
L<values|HTML::FormFu::Element::_Group/values> or 
L<options|HTML::FormFu::Element::_Group/options> provides the equivalent 
function.

=head2 value_xml

Arguments: $string

If you don't want the value to be XML-escaped, use the L</value_xml> 
method instead of L</value>.

=head2 value_loc

Arguments: $localization_key

Set the value using a L10N key.

=head2 non_param

Arguments: bool

If true, values for this field are never returned by L<HTML::FormFu/params>, 
L<HTML::FormFu/param> and L<HTML::FormFu/valid>.

This is useful for Submit buttons, when you only use its value as an 
L<indicator|HTML::FormFu/indicator>.

Default Value: false

=head2 label

Set a label to communicate the purpose of the form-field to the user.

=head2 label_xml

Arguments: $string

If you don't want the label to be XML-escaped, use the L</label_xml> 
method instead of L</label>.

=head2 label_loc

Arguments: $localization_key

Set the label using a L10N key.

=head2 placeholder

Sets the HTML5 attribute C<placeholder> to the specified value.

=head2 placeholder_xml

If you don't want the C<placeholder> attribute to be XML-escaped, use the L</placeholder_xml> 
method instead of L</placeholder>.

Arguments: $string

=head2 placeholder_loc

Arguments: $localization_key

Set the C<placeholder> attribute using a L10N key.

=head2 comment

Set a comment to be displayed along with the form-field.

=head2 comment_xml

Arguments: $string

If you don't want the comment to be XML-escaped, use the L</comment_xml> 
method instead of L</comment>.

=head2 comment_loc

Arguments: $localization_key

Set the comment using a L10N key.

=head2 container_tag

Set which tag-name should be used to contain the various field parts (field, 
label, comment, errors, etc.).

Default Value: 'div'

=head2 javascript

Arguments: [$javascript]

If set, the contents will be rendered within a C<script> tag, within the 
field's container.

=head2 retain_default

If L</retain_default> is true and the form was submitted, but the field 
didn't have a value submitted, then when the form is redisplayed to the user 
the field will have its value set to its default value, rather than the 
usual behaviour of having an empty value.

Default Value: C<false>

=head2 force_default

If L</force_default> is true and the form was submitted, and the field
has a default/value set, then when the form is redisplayed to the user
the field will have its value set to its default value.

If the default value is being changed after FormFu->process is being called
the later default value is respected for rendering, *but* nevertheless the
input value doesn't respect that, it will remain the first value.

Default Value: C<false>

=head2 default_empty_value

Designed for use by Checkbox fields. Normally if a checkbox is not checked,
no value is submitted for that field. If C<default_empty_value> is true,
the Checkbox field is given an empty value during
L<process|HTML::FormFu/process>. Please note that, with this setting,
the checkbox gets an EMPTY value (as opposed to no value at all without
enabling it), NOT the default value assigned to the element (if any).

Default Value: C<false>

=head2 reverse_single

If true, then the field's label should be rendered to the right of the
field control.  (When the field is used within a
L<Multi|HTML::FormFu::Element::Multi> block, the position of the label
is controlled by the L</reverse_multi> option instead.)

The default value is C<false>, causing the label to be rendered to the left
of the field control (or to be explicit: the markup for the label comes
before the field control in the source).

Exception: If the label tag is 'legend', then the reverse_single attribute
is ignored; the legend always appears as the first tag within the container
tag.

Default Value: C<false>

=head2 reverse_multi

If true, then when the field is used within a 
L<Multi|HTML::FormFu::Element::Multi> block, the field's label should be 
rendered to the right of the field control.

The default value is C<false>, causing the label to be rendered to the left
of the field control (or to be explicit: the markup for the label comes 
before the field control in the source).

Default Value: C<false>

=head2 repeatable_count

Only available for fields attached to a
L<Repeatable|HTML::FormFu::Element::Repeatable> element, after
L<< $repeatable->repeat($count) | HTML::FormFu::Element::Repeatable/repeat >>
has been called.

The value is inherited from
L<HTML::FormFu::Element::Repeatable/repeatable_count>.

=head2 clone

See L<HTML::FormFu/clone> for details.

=head2 deflators

See L<HTML::FormFu/deflators> for details.

=head2 deflator

See L<HTML::FormFu/deflator> for details.

=head1 ATTRIBUTES

=head2 comment_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Attributes added to the comment container.

=head2 comment_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</comment_attributes_xml> method instead of L</comment_attributes>.

=head2 add_comment_attributes

=head2 add_comment_attrs

See L<HTML::FormFu/add_attributes> for details.

=head2 add_comment_attributes_xml

=head2 add_comment_attrs_xml

See L<HTML::FormFu/add_attributes_xml> for details.

=head2 add_comment_attributes_loc

=head2 add_comment_attrs_loc

See L<HTML::FormFu/add_attributes_loc> for details.

=head2 del_comment_attributes

=head2 del_comment_attrs

See L<HTML::FormFu/del_attributes> for details.

=head2 del_comment_attributes_xml

=head2 del_comment_attrs_xml

See L<HTML::FormFu/del_attributes_xml> for details.

=head2 del_comment_attributes_loc

=head2 del_comment_attrs_loc

See L<HTML::FormFu/del_attributes_loc> for details.

=head2 container_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Arguments added to the field's container.

=head2 container_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</container_attributes_xml> method instead of L</container_attributes>.

=head2 add_container_attributes

=head2 add_container_attrs

See L<HTML::FormFu/add_attributes> for details.

=head2 add_container_attributes_xml

=head2 add_container_attrs_xml

See L<HTML::FormFu/add_attributes_xml> for details.

=head2 add_container_attributes_loc

=head2 add_container_attrs_loc

See L<HTML::FormFu/add_attributes_loc> for details.

=head2 del_container_attributes

=head2 del_container_attrs

See L<HTML::FormFu/del_attributes> for details.

=head2 del_container_attributes_xml

=head2 del_container_attrs_xml

See L<HTML::FormFu/del_attributes_xml> for details.

=head2 del_container_attributes_loc

=head2 del_container_attrs_loc

See L<HTML::FormFu/del_attributes_loc> for details.

=head2 label_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Attributes added to the label container.

=head2 label_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</label_attributes_xml> method instead of L</label_attributes>.

=head2 add_label_attributes

=head2 add_label_attrs

See L<HTML::FormFu/add_attributes> for details.

=head2 add_label_attributes_xml

=head2 add_label_attrs_xml

See L<HTML::FormFu/add_attributes_xml> for details.

=head2 add_label_attributes_loc

=head2 add_label_attrs_loc

See L<HTML::FormFu/add_attributes_loc> for details.

=head2 del_label_attributes

=head2 del_label_attrs

See L<HTML::FormFu/del_attributes> for details.

=head2 del_label_attributes_xml

=head2 del_label_attrs_xml

See L<HTML::FormFu/del_attributes_xml> for details.

=head2 del_label_attributes_loc

=head2 del_label_attrs_loc

See L<HTML::FormFu/del_attributes_loc> for details.

=head1 FORM LOGIC AND VALIDATION

=head2 filters

See L<HTML::FormFu/filters> for details.

=head2 filter

See L<HTML::FormFu/filter> for details.

=head2 constraints

See L<HTML::FormFu/constraints> for details.

=head2 constraint

See L<HTML::FormFu/constraint> for details.

=head2 inflators

See L<HTML::FormFu/inflators> for details.

=head2 inflator

See L<HTML::FormFu/inflator> for details.

=head2 validators

See L<HTML::FormFu/validators> for details.

=head2 validator

See L<HTML::FormFu/validator> for details.

=head2 transformers

See L<HTML::FormFu/transformers> for details.

=head2 transformer

See L<HTML::FormFu/transformer> for details.

=head1 CSS CLASSES

=head2 auto_id

See L<HTML::FormFu/auto_id> for details.

=head2 auto_label

See L<HTML::FormFu/auto_label> for details.

=head2 auto_error_class

See L<HTML::FormFu/auto_error_class> for details.

=head2 auto_error_message

See L<HTML::FormFu/auto_error_message> for details.

=head2 auto_constraint_class

See L<HTML::FormFu/auto_constraint_class> for details.

=head2 auto_inflator_class

See L<HTML::FormFu/auto_inflator_class> for details.

=head2 auto_validator_class

See L<HTML::FormFu/auto_validator_class> for details.

=head2 auto_transformer_class

See L<HTML::FormFu/auto_transformer_class> for details.

=head1 RENDERING

=head2 field_filename

The template filename to be used for just the form field - not including the 
display of any container, label, errors, etc. 

Must be set by more specific field classes.

=head2 label_filename

The template filename to be used to render the label.

Must be set by more specific field classes.

=head1 ERROR HANDLING

=head2 get_errors

See L<HTML::FormFu/get_errors> for details.

=head2 add_error

=head2 clear_errors

See L<HTML::FormFu/clear_errors> for details.

=head1 INTROSPECTION

=head2 get_deflators

See L<HTML::FormFu/get_deflators> for details.

=head2 get_deflator

See L<HTML::FormFu/get_deflator> for details.

=head2 get_filters

See L<HTML::FormFu/get_filters> for details.

=head2 get_filter

See L<HTML::FormFu/get_filter> for details.

=head2 get_constraints

See L<HTML::FormFu/get_constraints> for details.

=head2 get_constraint

See L<HTML::FormFu/get_constraint> for details.

=head2 get_inflators

See L<HTML::FormFu/get_inflators> for details.

=head2 get_inflator

See L<HTML::FormFu/get_inflator> for details.

=head2 get_validators

See L<HTML::FormFu/get_validators> for details.

=head2 get_validator

See L<HTML::FormFu/get_validator> for details.

=head2 get_transformers

See L<HTML::FormFu/get_transformers> for details.

=head2 get_transformer

See L<HTML::FormFu/get_transformer> for details.

=head2 get_errors

See L<HTML::FormFu/get_errors> for details.

=head2 clear_errors

See L<HTML::FormFu/clear_errors> for details.

=head1 SEE ALSO

Base-class for L<HTML::FormFu::Element::_Group>, 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::Multi>, 
L<HTML::FormFu::Element::ContentButton>, 
L<HTML::FormFu::Element::Textarea>.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
