package HTML::FormFu::Element::_Group;

use strict;
use base 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::ObjectUtil qw/ _coerce /;
use HTML::FormFu::Util qw/ append_xml_attribute literal /;
use Storable qw( dclone );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ _options empty_first /);

my @ALLOWED_OPTION_KEYS = qw/
    group
    value
    label
    attributes
    attrs
    attributes_xml
    attrs_xml
    label_attributes
    label_attrs
    label_attributes_xml
    label_attrs_xml
    /;

sub new {
    my $self = shift->next::method(@_);

    $self->_options( [] );
    $self->container_attributes( {} );

    return $self;
}

sub process {
    my ($self) = @_;

    my $args = $self->db;

    if ( $args and keys %$args ) {
        $self->options(
            [ $self->form->model->options_from_model( $self, $args ) ] );
    }
}

sub options {
    my ( $self, $arg ) = @_;
    my ( @options, @new );

    croak "options argument must be a single array-ref" if @_ > 2;

    if ( defined $arg ) {
        eval { @options = @$arg };
        croak "options argument must be an array-ref" if $@;

        if ( $self->empty_first ) {
            push @new,
                {
                value            => '',
                label            => '',
                attributes       => {},
                label_attributes => {},
                };
        }

        for my $item (@options) {
            push @new, $self->_parse_option($item);
        }
    }

    $self->_options( \@new );

    return $self;
}

sub _parse_option {
    my ( $self, $item ) = @_;

    eval { my %x = %$item };

    if ( !$@ ) {

        # was passed a hashref

        return $self->_parse_option_hashref($item);
    }

    eval { my @x = @$item };
    if ( !$@ ) {

        # was passed an arrayref

        return {
            value            => $item->[0],
            label            => $item->[1],
            attributes       => {},
            label_attributes => {},
        };
    }

    croak "each options argument must be a hash-ref or array-ref";
}

sub _parse_option_hashref {
    my ( $self, $item ) = @_;

    # sanity check options
    my @keys = keys %$item;

    for my $key (@keys) {
        croak "unknown option argument: '$key'"
            if !grep { $key eq $_ } @ALLOWED_OPTION_KEYS;

        my $short = $key;

        if ( $short =~ s/attributes/attrs/ ) {
            for my $cmp (@keys) {
                next if $cmp eq $key;
                croak "cannot use both '$key' and '$short' arguments"
                    if $cmp eq $short;
            }
        }
    }

    if ( exists $item->{group} ) {
        my @group = @{ $item->{group} };
        my @new;
        for my $groupitem (@group) {
            push @new, $self->_parse_option($groupitem);
        }
        my %group = ( group => \@new );
        $group{label} = $item->{label};
        $group{label} = $self->form->localize( $item->{label_loc} )
            if defined $item->{label_loc};
        $group{attributes} = $item->{attributes} || {};

        return \%group;
    }

    if ( !exists $item->{attributes} ) {
        $item->{attributes}
            = exists $item->{attrs}
            ? $item->{attrs}
            : {};
    }

    if ( exists $item->{attributes_xml} ) {
        for my $key ( keys %{ $item->{attributes_xml} } ) {
            $item->{attributes}{$key}
                = literal( $item->{attributes_xml}{$key} );
        }
    }
    elsif ( exists $item->{attrs_xml} ) {
        for my $key ( keys %{ $item->{attrs_xml} } ) {
            $item->{attributes}{$key} = literal( $item->{attrs_xml}{$key} );
        }
    }

    if ( !exists $item->{label_attributes} ) {
        $item->{label_attributes}
            = exists $item->{label_attrs}
            ? $item->{label_attrs}
            : {};
    }

    if ( exists $item->{label_attributes_xml} ) {
        for my $key ( keys %{ $item->{label_attributes_xml} } ) {
            $item->{label_attributes}{$key}
                = literal( $item->{label_attributes_xml}{$key} );
        }
    }
    elsif ( exists $item->{label_attrs_xml} ) {
        for my $key ( keys %{ $item->{label_attrs_xml} } ) {
            $item->{label_attributes}{$key}
                = literal( $item->{label_attrs_xml}{$key} );
        }
    }

    $item->{label} = $self->form->localize( $item->{label_loc} )
        if defined $item->{label_loc};

    $item->{value} = '' if !defined $item->{value};

    return $item;
}

sub values {
    my ( $self, $arg ) = @_;
    my ( @values, @new );

    croak "values argument must be a single array-ref of values" if @_ > 2;

    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "values argument must be an array-ref" if $@;
    }

    if ( $self->empty_first ) {
        unshift @values, '';
    }

    @new = (
        map { { value            => $_,
                label            => ucfirst $_,
                attributes       => {},
                label_attributes => {},
            }
            } @values
    );

    $self->_options( \@new );

    return $self;
}

sub value_range {
    my ( $self, $arg ) = @_;
    my (@values);

    croak "value_range argument must be a single array-ref of values" if @_ > 2;

    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "value_range argument must be an array-ref" if $@;
    }

    croak "range must contain at least 2 values" if @$arg < 2;

    my $end   = pop @values;
    my $start = pop @values;

    if ( $self->empty_first ) {
        unshift @values, '';
    }

    return $self->values( [ @values, $start .. $end ] );
}

sub prepare_attrs {
    my ( $self, $render ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;
    my $value
        = defined $self->name
        ? $self->get_nested_hash_value( $self->form->input, $self->nested_name )
        : undef;

    for my $option ( @{ $render->{options} } ) {
        if ( exists $option->{group} ) {
            for my $item ( @{ $option->{group} } ) {
                $self->_prepare_attrs( $submitted, $value, $default, $item );
            }
        }
        else {
            $self->_prepare_attrs( $submitted, $value, $default, $option );
        }
    }

    $self->next::method($render);

    return;
}

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->next::method( {
            options => dclone( $self->_options ),
            @_ ? %{ $_[0] } : () } );

    return $render;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # input_tag template

    $html .= $self->_string_field($render);

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub as {
    my ( $self, $type, %attrs ) = @_;

    return $self->_coerce(
        type       => $type,
        attributes => \%attrs,
        errors     => $self->_errors,
        package    => __PACKAGE__,
    );
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->_options( dclone $self->_options );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::_Group - grouped form field base-class

=head1 DESCRIPTION

Base class for L<HTML::FormFu::Element::Radiogroup> and 
L<HTML::FormFu::Element::Select> fields.

=head1 METHODS

=head2 options

Arguments: \@options

    ---
    elements:
      - type: Select
        name: foo
        options:
          - [ 01, January ]
          - [ 02, February ]
          - value: 03
            label: March
            attributes:
              style: highlighted
          - [ 04, April ]

Use to set the list of items in the select menu / radiogroup.

It's arguments must be an array-ref of items. Each item may be an array ref 
of the form C<[ $value, $label ]> or a hash-ref of the form 
C<< { value => $value, label => $label } >>. Each hash-ref may also have the 
keys C<attributes> and C<label_attributes>.

Passing an item containing a C<group> key will, for 
L<Select fields|HTML::FormFu::Element::Select>, create an optgroup. And for 
L<RadioGroup fields|HTML::FormFu::Element::RadioGroup>, create a sub-group 
of radiobuttons with a new C<span> block, with the classname C<subgroup>.

An example of Select optgroups:

    ---
    elements:
      - type: Select
        name: foo
        options:
          - label: "group 1"
            group:
              - [1a, 'item 1a']
              - [1b, 'item 1b']
          - label: "group 2"
            group:
              - [2a, 'item 2a']
              - [2b, 'item 2b']

The usage of label_loc instead of label is supported to translate a given
string. label_loc is supported for items and option groups.

=head2 values

Arguments: \@values

    ---
    elements:
      - type: Radiogroup
        name: foo
        values:
          - jan
          - feb
          - mar
          - apr

A more concise alternative to L</options>. Use to set the list of values in 
the select menu / radiogroup.

It's arguments must be an array-ref of values. The labels used are the 
result of C<ucfirst($value)>.

=head2 value_range

Arguments: \@values

    ---
    elements:
      - type: Select
        name: foo
        value_range:
          - ""
          - 1
          - 12 

Similar to L</values>, but the last 2 values are expanded to a range. Any 
preceeding values are used literally, allowing the common empty first item 
in select menus.

=head2 empty_first

If true, then a blank option will be inserted at the start of the option list
(regardless of whether L</options>, L</values> or L</value_range> was used to
populate the options).

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
