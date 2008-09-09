package HTML::FormFu::Element::_Group;

use strict;
use base 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::ObjectUtil qw( _coerce );
use HTML::FormFu::Util qw( append_xml_attribute literal xml_escape );
use Exporter qw( import );
use List::MoreUtils qw( none );
use Storable qw( dclone );
use Carp qw( croak );

our @EXPORT_OK = qw( _process_options_from_model ); # used by ComboBox

__PACKAGE__->mk_item_accessors( qw( _options empty_first ) );
__PACKAGE__->mk_output_accessors( qw( empty_first_label ) );

my @ALLOWED_OPTION_KEYS = qw(
    group
    value
    value_xml
    value_loc
    label
    label_xml
    label_loc
    attributes
    attrs
    attributes_xml
    attrs_xml
    label_attributes
    label_attrs
    label_attributes_xml
    label_attrs_xml
);

sub new {
    my $self = shift->next::method(@_);

    $self->_options            ( [] );
    $self->container_attributes( {} );

    return $self;
}

sub process {
    my $self = shift;

    $self->next::method(@_);

    $self->_process_options_from_model;

    return;
}

sub _process_options_from_model {
    my ($self) = @_;

    my $args = $self->model_config;

    return if !$args || !keys %$args;

    return if @{ $self->options };

    # don't run if {options_from_model} is set and is 0

    my $option_flag
        = exists $args->{options_from_model} ? $args->{options_from_model}
        :                                      1
        ;

    return if !$option_flag;

    $self->options(
        [ $self->form->model->options_from_model( $self, $args ) ]
    );

    return;
}

sub options {
    my ( $self, $arg ) = @_;
    my ( @options, @new );

    return $self->_options if @_ == 1;

    croak "options argument must be a single array-ref" if @_ > 2;

    if ( defined $arg ) {
        eval { @options = @$arg };
        croak "options argument must be an array-ref" if $@;

        if ( $self->empty_first ) {
            push @new, $self->_get_empty_first_option;
        }

        for my $item (@options) {
            push @new, $self->_parse_option($item);
        }
    }

    $self->_options( \@new );

    return $self;
}

sub _get_empty_first_option {
    my ($self) = @_;

    my $label = $self->empty_first_label || '';

    return {
        value            => '',
        label            => $label,
        attributes       => {},
        label_attributes => {},
    };
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
            if none { $key eq $_ } @ALLOWED_OPTION_KEYS;

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
        $item->{group} = \@new;
    }

    if ( !exists $item->{attributes} ) {
        $item->{attributes} = exists $item->{attrs} ? $item->{attrs}
                            :                         {}
                            ;
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
            = exists $item->{label_attrs} ? $item->{label_attrs}
            :                               {}
            ;
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

    if ( defined $item->{label_xml} ) {
        $item->{label} = literal( $item->{label_xml} );
    }
    elsif ( defined $item->{label_loc} ) {
        $item->{label} = $self->form->localize( $item->{label_loc} );
    }

    if ( defined $item->{value_xml} ) {
        $item->{value} = literal( $item->{value_xml} );
    }
    elsif ( defined $item->{value_loc} ) {
        $item->{value} = $self->form->localize( $item->{value_loc} );
    }

    if ( !defined $item->{value} ) {
        $item->{value} = '';
    }

    return $item;
}

sub values {
    my ( $self, $arg ) = @_;

    croak "values argument must be a single array-ref of values" if @_ > 2;

    my @values;
    
    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "values argument must be an array-ref" if $@;
    }

    my @new = map { {
        value            => $_,
        label            => ucfirst $_,
        attributes       => {},
        label_attributes => {},
        } } @values;
    
    if ( $self->empty_first ) {
        unshift @new, $self->_get_empty_first_option;
    }

    $self->_options( \@new );

    return $self;
}

sub value_range {
    my ( $self, $arg ) = @_;
    my (@values);

    croak "value_range argument must be a single array-ref of values"
        if @_ > 2;

    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "value_range argument must be an array-ref" if $@;
    }

    croak "range must contain at least 2 values" if @$arg < 2;

    my $end   = pop @values;
    my $start = pop @values;

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
    my ( $self, $args ) = @_;

    my $render = $self->next::method( {
        options => dclone( $self->_options ),
        $args ? %$args : (),
    } );

    $self->_quote_options( $render->{options} );

    return $render;
}

sub _quote_options {
    my ( $self, $options ) = @_;

    foreach my $opt (@$options) {
        $opt->{label} = xml_escape( $opt->{label} );
        $opt->{value} = xml_escape( $opt->{value} );

        if ( exists $opt->{group} ) {
            $self->_quote_options( $opt->{group} );
        }
    }
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render = exists $args->{render_data} ? $args->{render_data}
               :                               $self->render_data
               ;

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

Arguments: none

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

If passed no arguments, it returns an arrayref of the currently set options.

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

When using the hash-ref construct, the C<label_xml> and C<label_loc> 
variants of C<label> are supported, as are the C<value_xml> and C<value_loc> 
variants of C<value>, the C<attributes_xml> variant of C<attributes> and the 
C<label_attributes_xml> variant of C<label_attributes>.

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
populate the options).  See also L</empty_first_label>.

=head2 empty_first_label

=head2 empty_first_label_xml

=head2 empty_first_label_loc

If L</empty_first> is true, and C<empty_first_label> is set, this value will
be used as the label for the first option - so only the first option's value
will be empty.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
