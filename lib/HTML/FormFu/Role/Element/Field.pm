use strict;
package HTML::FormFu::Role::Element::Field;


use Moose::Role;
use MooseX::Aliases;

with 'HTML::FormFu::Role::ContainsElementsSharedWithField',
    'HTML::FormFu::Role::NestedHashUtils',
    'HTML::FormFu::Role::FormBlockAndFieldMethods',
    'HTML::FormFu::Role::Element::Layout';

use HTML::FormFu::Attribute qw(
    mk_attrs
    mk_output_accessors
);
use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw(
    _parse_args                 append_xml_attribute
    xml_escape                  require_class
    process_attrs               _filter_components
);
use Class::MOP::Method;
use Clone ();
use List::Util 1.45 qw( uniq );
use Carp qw( croak carp );

__PACKAGE__->mk_attrs( qw(
        comment_attributes
        container_attributes
        label_attributes
        error_attributes
        error_container_attributes
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
has default_empty_value  => ( is => 'rw', traits => ['Chained'] );

__PACKAGE__->mk_output_accessors(qw( comment label value ));

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
    $self->comment_attributes(         {} );
    $self->container_attributes(       {} );
    $self->label_attributes(           {} );
    $self->error_attributes(           {} );
    $self->error_container_attributes( {} );
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
                if ( defined $parent->original_name ) {
                    push @names, $parent->original_name;
                }
                elsif ( defined $parent->name ) {
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
                if ( $parent->can('original_nested_name')
                    && defined $parent->original_nested_name )
                {
                    push @names, $parent->original_nested_name;
                }
                elsif ( defined $parent->nested_name ) {
                    push @names, $parent->nested_name;
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
    elsif ($submitted
        && $self->force_default
        && $self->can('checked')
        && $self->checked )
    {

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

    my $render = $self->$orig( {
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
            error_container_tag  => $self->error_container_tag,
            error_tag            => $self->error_tag,
            reverse_single       => $self->reverse_single,
            reverse_multi        => $self->reverse_multi,
            javascript           => $self->javascript,
            $args ? %$args : (),
        } );

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

    if (    defined $render->{label}
         && defined $self->auto_label_class
         && length $self->auto_label_class
        )
    {
        my $form_name
            = defined $self->form->id
            ? $self->form->id
            : $EMPTY_STR;

        my $field_name
            = defined $render->{nested_name}
            ? $render->{nested_name}
            : $EMPTY_STR;

        my $type = lc $self->type;
        $type =~ s/:://g;

        my %string = (
            f => $form_name,
            n => $field_name,
            t => $type,
        );

        my $class = $self->auto_label_class;
        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{label_attributes},
            'class', $class );
    }

    if (    defined $render->{label}
         && defined $self->auto_container_label_class
         && length $self->auto_container_label_class
        )
    {
        my $form_name
            = defined $self->form->id
            ? $self->form->id
            : $EMPTY_STR;

        my $field_name
            = defined $render->{nested_name}
            ? $render->{nested_name}
            : $EMPTY_STR;

        my $type = lc $self->type;
        $type =~ s/:://g;

        my %string = (
            f => $form_name,
            n => $field_name,
            t => $type,
        );

        my $class = $self->auto_container_label_class;
        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class );
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

    if (    defined $render->{comment}
         && defined $self->auto_comment_class
         && length $self->auto_comment_class
        )
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

        my $class = $self->auto_comment_class;
        $class =~ s/%([fn])/$string{$1}/g;

        append_xml_attribute( $render->{comment_attributes},
            'class', $class );
    }

    if (    defined $render->{comment}
         && defined $self->auto_container_comment_class
         && length $self->auto_container_comment_class
        )
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

        my $class = $self->auto_container_comment_class;
        $class =~ s/%([fn])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class );
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

    if (    defined $self->auto_container_class
         && length $self->auto_container_class
        )
    {
        my $form_name
            = defined $self->form->id
            ? $self->form->id
            : $EMPTY_STR;

        my $field_name
            = defined $render->{nested_name}
            ? $render->{nested_name}
            : $EMPTY_STR;

        my $type = lc $self->type;
        $type =~ s/:://g;

        my %string = (
            f => $form_name,
            n => $field_name,
            t => $type,
        );

        my $class = $self->auto_container_class;
        $class =~ s/%([fnt])/$string{$1}/g;

        append_xml_attribute( $render->{container_attributes},
            'class', $class );
    }

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

    return if !@errors;

    @errors = map { $_->render_data } @errors;

    $render->{errors} = \@errors;

    # auto_error_field_class
    my $field_class = $self->auto_error_field_class;

    if ( defined $field_class && length $field_class ) {
        my %string = (
            f => sub { defined $self->form->id ? $self->form->id   : '' },
            n => sub { defined $render->{name} ? $render->{name}   : '' },
        );

        $field_class =~ s/%([fn])/$string{$1}->()/ge;

        append_xml_attribute( $render->{attributes}, 'class', $field_class );
    }

    my @container_class;

    # auto_container_error_class
    my $auto_class = $self->auto_container_error_class;

    if ( defined $auto_class && length $auto_class ) {
        my %string = (
            f => sub { defined $self->form->id ? $self->form->id   : '' },
            n => sub { defined $render->{name} ? $render->{name}   : '' },
        );

        $auto_class =~ s/%([fn])/$string{$1}->()/ge;

        push @container_class, $auto_class;
    }

    # auto_container_per_error_class
    my $item_class = $self->auto_container_per_error_class;

    if ( defined $item_class && length $item_class ) {
        for my $error (@errors) {
            my %string = (
                f => sub { defined $self->form->id ? $self->form->id   : '' },
                n => sub { defined $render->{name} ? $render->{name}   : '' },
                s => sub { $error->{stage} },
                t => sub { lc $error->{type} },
            );

            my $string = $item_class;
            $string =~ s/%([fnst])/$string{$1}->()/ge;

            push @container_class, $string;
        }
    }

    map {
        append_xml_attribute( $render->{container_attributes}, 'class', $_ )
    } uniq @container_class;

    my @error_container_class;

    if ( $self->error_container_tag ) {

        # auto_error_container_class
        my $auto_class = $self->auto_error_container_class;

        if ( defined $auto_class && length $auto_class ) {
            my %string = (
                f => sub { defined $self->form->id ? $self->form->id   : '' },
                n => sub { defined $render->{name} ? $render->{name}   : '' },
            );

            $auto_class =~ s/%([fn])/$string{$1}->()/ge;

            push @error_container_class, $auto_class;
        }

        # auto_container_per_error_class
        my $item_class = $self->auto_container_per_error_class;

        if ( defined $item_class && length $item_class ) {
            for my $error (@errors) {
                my %string = (
                    f => sub { defined $self->form->id ? $self->form->id   : '' },
                    n => sub { defined $render->{name} ? $render->{name}   : '' },
                    s => sub { $error->{stage} },
                    t => sub { lc $error->{type} },
                );

                my $string = $item_class;
                $string =~ s/%([fnst])/$string{$1}->()/ge;

                push @error_container_class, $string;
            }
        }

         map {
            append_xml_attribute( $render->{error_container_attributes}, 'class', $_ )
        } uniq @error_container_class;
    }

    return;
}

sub render_label {
    my ($self) = @_;

    my $render = $self->render_data;

    return $self->_string_label( $render );
}

sub render_field {
    my ($self) = @_;

    my $render = $self->render_data;

    return $self->_string_field( $render );
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

    $html .= $self->_string_errors( $render );

    if (   defined $render->{label}
        && $render->{label_tag} ne 'legend'
        && !$render->{reverse_single} )
    {
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

sub _string_errors {
    my ( $self, $render ) = @_;

    return '' if !$render->{errors};

    my $html = '';

    if ( $render->{error_container_tag} ) {
        $html .= sprintf qq{<%s%s>\n},
            $render->{error_container_tag},
            process_attrs( $render->{error_container_attributes} ),
            ;
    }

    # work around leaky abstraction to fix #24
    my $default_error_attributes = defined $self->{error_attributes}
                                 ? $self->{error_attributes}
                                 : $render->{error_attributes};
    my @error_html;
    for my $error ( @{ $render->{errors} } ) {
        my $error_attributes = %{ $error->{attributes}}
                             ? $error->{attributes}
                             : $default_error_attributes;
        push @error_html, sprintf qq{<%s%s>%s</%s>},
            $render->{error_tag},
            process_attrs( $error_attributes ),
            $error->{message},
            $render->{error_tag},
            ;
    }
    $html .= join "\n", @error_html;

    if ( $render->{error_container_tag} ) {
        $html .= sprintf qq{\n</%s>}, $render->{error_container_tag};
    }

    return $html;
}

sub _string_field_end {
    my ( $self, $render ) = @_;

    # field wrapper template - end

    my $html = '';

    if (   defined $render->{label}
        && $render->{label_tag} ne 'legend'
        && $render->{reverse_single} )
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

HTML::FormFu::Role::Element::Field - Role for all form-field elements

=head1 DESCRIPTION

Base-class for all form-field elements.

=head1 METHODS

=head2 default

Set the form-field's default value.

Is an L<output accessor|HTML::FormFu/OUTPUT ACCESSORS>.

=head2 value

For most fields, L</value> is an alias for L</default>.

For the L<HTML::FormFu::Element::Checkbox> and
L<HTML::FormFu::Element::Radio> elements, L</value> sets what the value of
the field will be if it is checked or selected. If the L</default> is the
same as the L</value>, then the field will be checked or selected when
rendered.

For the L<HTML::FormFu::Element::Radiogroup> and
L<HTML::FormFu::Element::Select> elements, the L</value> is ignored:
L<values|HTML::FormFu::Role::Element::Group/values> or
L<options|HTML::FormFu::Role::Element::Group/options> provides the equivalent
function.

Is an L<output accessor|HTML::FormFu/OUTPUT ACCESSORS>.

=head2 non_param

Arguments: bool

Default Value: false

If true, values for this field are never returned by L<HTML::FormFu/params>,
L<HTML::FormFu/param> and L<HTML::FormFu/valid>.

This is useful for Submit buttons, when you only use its value as an
L<indicator|HTML::FormFu/indicator>

=head2 placeholder

Sets the HTML5 attribute C<placeholder> to the specified value.

Is an L<output accessor|HTML::FormFu/OUTPUT ACCESSORS>.

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

=head2 auto_datalist_id

Arguments: [$string]

If any L<Input|HTML::FormFu::Role::Element::Input> element had a datalist,
but does not have L<HTML::FormFu::Role::Element::Input/datalist_id> set,
L</auto_datalist_id> is used to generate the datalist id.

The following character substitution will be performed: C<%f> will be
replaced by L<< $form->id|/id >>, C<%n> will be replaced by
L<< $field->name|HTML::FormFu::Element/name >>, C<%r> will be replaced by
L<< $block->repeatable_count|HTML::FormFu::Element::Repeatable/repeatable_count >>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

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

=head1 CUSTOMIZING GENERATED MARKUP

Each field is, by default, wrapped in a container.
Each container may also contain a label, a comment, and after an invalid
submission may contain 1 or more error messages.

Example of generated form:

    1   <form action="" method="post">
    2       <div class="has-errors">    # container
    3           <ul class="errors">     # error container
    4               <li>                # error message
    5                   This field must contain an email address
    6               </li>
    7           </li>
    8           <label>Foo</label>      # label
    9           <input name="foo" type="text" value="example.com" />
    10          <span class="comment">  # comment
    11              This is Foo
    12          </span>
    13      </div>
    14  </form>

    # Line 2 starts the 'container' - by default a DIV.
    # Line 2 starts an error container, which may contain 1 or more error
             messages - in this case, a unordered list (UL).
    # Line 4 starts a single error message - in this case, a list item (LI).
    # Line 8 shows a 'label'.
    # Line 9 shows the field's 'input' tag.
    # Lines 10 starts a 'comment'.

To re-order the various parts of each form (label, input, errors, etc) and
arbitrary extra tags, see the L<layout|/layout> method.

=head2 CONTAINER

=head3 container_tag

Default value: 'div'

The container wrapping each entire field, any label, comment, and errors.

=head3 container_attributes

Attributes added to the container tag.

Is an L<attribute accessor|HTML::FormFu/ATTRIBUTE ACCESSOR>.

=head3 auto_container_class

Default Value: '%t'

If set, then the container of each field will be given a class-name based on
the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_container_label_class

Default Value: 'label'

If set, and if the field has a L<label|/label>, the container will be given a
class-name based on the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_container_comment_class

Default Value: '%t'

If set, and if the field has a
L<comment|HTML::FormFu::Role::Element::Field/comment>, the container will be
given a class-name based on the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_container_error_class

Default Value: 'error'

If set, then the container of each field with an error will be given a
class-name based on the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_container_per_error_class

Default Value: 'error_%s_%t'

If set, then the container of each field with an error will be given a
class-name based on the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>, C<%s>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 FORM FIELD

=head3 auto_id

If set, then the field will be given an L<id|HTML::FormFu::Element/id>
attribute, if it doesn't have one already.

E.g., setting C<< $form->auto_id('%n') >> will make each field have an ID
the same as the field's name. This makes our form config simpler, and ensures
we don't need to manually update IDs if any field names are changed.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%r>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 LABEL

=head3 label

Set a label to communicate the purpose of the form-field to the user.

Is an L<output accessor|HTML::FormFu/OUTPUT ACCESSORS>.

=head3 auto_label

If L<label|/label> isn't already set, the value of L</auto_label> is passed through
L<localize|HTML::FormFu/localize> to generate a label.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>.

The generated string will be passed to L</localize> to create the label.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 label_tag

Default value: 'label'
(except L<Checkboxgroup|HTML::FormFu::Element::Checkboxgroup>)

Default value: 'legend'
(only L<Checkboxgroup|HTML::FormFu::Element::Checkboxgroup>)

Set which tag is used to wrap a L<label|/label>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 label_attributes

Attributes added to the label container.

Is an L<attribute accessor|HTML::FormFu/ATTRIBUTE ACCESSOR>.

=head2 COMMENT

=head3 comment

Set a comment to be displayed along with the form-field.

Is an L<output accessor|HTML::FormFu/OUTPUT ACCESSORS>.

=head3 comment_attributes

Attributes added to the comment container.

Is an L<attribute accessor|HTML::FormFu/ATTRIBUTE ACCESSOR>.

=head3 auto_comment_class

Default Value: '%t'

If set, and if the field has a
L<comment|HTML::FormFu::Role::Element::Field/comment>, the comment tag will
be given a class-name based on the given pattern.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 ERROR CONTAINER

=head3 error_container_tag

If set, and if the field has any errors, a container of this type is
wrapped around all of the field error messages.

    # Example - this would wrap each individual error in a 'li' tag,
    # with a single 'ul' tag wrapped around all the errors.

    element:
      name: foo
      error_container_tag: ul
      error_tag: li

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_error_container_class

Add a class-name to the error container.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_error_container_per_error_class

Add a class-name to the error container for each error on that field.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>, C<%s>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 ERROR MESSAGES

=head3 error_tag

Default value: 'span'

Sets the tag used to wrap each individual error message.

Defaults to C<span>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.


=head3 auto_error_message

Default Value: 'form_%s_%t'

If set, then each error will be given an auto-generated
L<message|HTML::FormFu::Exception::Input/message>, if it doesn't have one
already.

The generated string will be passed to L</localize> to create the message.

For example, a L<Required constraint|HTML::FormFu::Constraint::Required>
will return the string C<form_constraint_required>. Under the default
localization behaviour, the appropriate message for
C<form_constraint_required> will be used from the default I18N package.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>, C<%s>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 error_attributes

Set attributes on the tag of each error message.

Is an L<attribute accessor|HTML::FormFu/ATTRIBUTE ACCESSOR>.

=head3 auto_error_field_class

Upon error, add a class name firectly to the field tag (e.g. C<input>, C<select> tag).

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>.

=head3 auto_error_class

Default Value: 'error_%s_%t'

Add a class-name to the tag of each error message.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>, C<%s>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 PROCESSOR CLASSES

=head3 auto_constraint_class

Add a class-name to the container tag, for each constraint added to the field.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_inflator_class

Add a class-name to the container tag, for each inflator added to the field.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_validator_class

Add a class-name to the container tag, for each validator added to the field.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head3 auto_transformer_class

Add a class-name to the container tag, for each transformer added to the field.

Supports L<substitutions|HTML::FormFu/ATTRIBUTE SUBSTITUTIONS>: C<%f>, C<%n>, C<%t>.

Is an L<inheriting accessor|HTML::FormFu/INHERITING ACCESSORS>.

=head2 REORDERING FIELD COMPONENTS

=head2 layout

Specify the order that each sub-part of the element should appear in the
rendered markup.

    # Default Value
    $element->layout( [
        'errors',
        'label',
        'field',
        'comment',
        'javascript',
    ] );

Example: Move the form field (the input tag or equivalent) inside the label
tag, after the label text.
Remove the comment - this will now never be rendered.

    # YAML config
    layout:
      - errors
      - label:
          - label_text
          - field
      - javascript

    # prettified example of rendered markup
    <div>
        <span>This field is required.</span>
        <label>
            Foo
            <input name="foo" type="text" />
        </label>
    </div>

Example: Don't wrap the label text inside it's usual tag.
Insert the form field (the input tag or equivalent) inside an arbitrary
extra tag.

    # YAML config
    layout:
      - errors
      - label_text
      -
        div:
          attributes:
            class: xxx
          content: field
      - comment
      - javascript

    # prettified example of rendered markup
    <div>
        <span>This field is required.</span>
        Foo
        <div class="xxx">
            <input name="foo" type="text" />
        </div>
    </div>

The following elements override the default L<layout> value:

=over

=item L<HTML::FormFu::Element::Checkboxgroup|HTML::FormFu::Element::Checkboxgroup>

=item L<HTML::FormFu::Element::Hidden|HTML::FormFu::Element::Hidden>

=back

=head3 Specification

The L<layout|/layout> method accepts an array-ref, hash-ref, or string
argument.

The processing is recursive, so each item in an array-ref may be any value
accepted by the L<layout|/layout> method.

A hash-ref must contain a single key and value pair.
If the hash key is the string C<label>, it creates a C<label> tag, using any
previously defined L<LABEL|/LABEL> customizations.
This allows the label tag to contains other elements, such as the form field.

All other hash key values are asssumed to be an arbitrary block tag name.
The value must be a hash-ref, and may contain one or both C<attributes> or
C<content> keys.

Any C<attributes> value must be a hash-ref, whose key/values are added to
the block tag. No processing or expansion is done to the C<attributes>
hash-ref at all.

The C<content> value may be anything accepted by the L<layout|/layout>
method.

The following strings are accepted:

=over

=item errors

Renders the element error messages.

See L<ERROR CONTAINER|/"ERROR CONTAINER"> and
L<ERROR MESSAGES|/"ERROR MESSAGES"> to customize the tags and attributes.

=item label

Renders the element L<label|/label>.

See L<LABEL|/LABEL> to customize the tag and attributes.

=item label_text

Renders the element L<label|/label> text, without the usual
L<label_tag|/label_tag>.

=item field

Renders the form field control (an input tag, button, or other control).

=item comment

Renders the element L<comment|/comment>.

See L<COMMENT|/COMMENT> to customize the tag and attributes.

=item javascript

Renders a C<script> tag containing any L<javascript|/javascript>.

=back

=head2 multi_layout

Specify the order that each sub-part of each element within a
L<HTML::FormFu::Element::Multi|HTML::FormFu::Element::Multi> should
appear in the rendered markup.

    # Default Value
    $element->multi_layout( [
        'label',
        'field',
    ] );

Example: Swap the label/field order. This is equivalent to the
now-deprecated L<reverse_multi|/reverse_multi> method.

    # YAML config
    multi_layout:
      - field
      - label

The following elements override the default C<multi_layout> value:

=over

=item L<HTML::FormFu::Element::Checkbox|HTML::FormFu::Element::Checkbox>

=back

=head1 RENDERING

=head2 field_filename

The template filename to be used for just the form field - not including the
display of any container, label, errors, etc.

Must be set by more specific field classes.

=head2 label_filename

The template filename to be used to render the label.

Defaults to C<label>.

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

=head1 DEPRECATED METHODS

=over

=item reverse_single

See L<layout|/layout> instead.

=item reverse_multi

See L<multi_layout|/multi_layout> instead.

=item errors_filename

See L<layout_errors_filename|/layout_errors_filename> instead.

=back

=head1 SEE ALSO

Base-class for L<HTML::FormFu::Role::Element::Group>,
L<HTML::FormFu::Role::Element::Input>,
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
