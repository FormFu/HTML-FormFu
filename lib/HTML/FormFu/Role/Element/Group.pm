package HTML::FormFu::Role::Element::Group;

use Moose::Role;
use MooseX::Attribute::FormFuChained;

with 'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::SingleValueField',
    'HTML::FormFu::Role::Element::ProcessOptionsFromModel',
    'HTML::FormFu::Role::Element::Coercible';

use HTML::FormFu::Attribute qw( mk_output_accessors );
use HTML::FormFu::Util qw( append_xml_attribute literal xml_escape );
use Clone ();
use List::MoreUtils qw( none );
use Scalar::Util qw( reftype );
use Carp qw( croak );

has empty_first => ( is => 'rw', traits => ['FormFuChained'] );

__PACKAGE__->mk_output_accessors(qw( empty_first_label ));

has _options => (
    is      => 'rw',
    default => sub { [] },
    lazy    => 1,
    isa     => 'ArrayRef',
);

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
    container_attributes
    container_attrs
    container_attributes_xml
    container_attrs_xml
    label_attributes
    label_attrs
    label_attributes_xml
    label_attrs_xml
);

after BUILD => sub {
    my $self = shift;

    $self->container_attributes( {} );

    return;
};

after process => sub {
    my $self = shift;

    $self->_process_options_from_model;

    return;
};

sub options {
    my ( $self, $arg ) = @_;
    my ( @options, @new );

    return $self->_options if @_ == 1;

    croak "options argument must be a single array-ref" if @_ > 2;

    if ( defined $arg ) {
        croak "options argument must be an array-ref"
            if reftype($arg) ne 'ARRAY';

        @options = @$arg;

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
        value                => '',
        label                => $label,
        attributes           => {},
        container_attributes => {},
        label_attributes     => {},
    };
}

sub _parse_option {
    my ( $self, $item ) = @_;

    if ( reftype($item) eq 'HASH' ) {
        return $self->_parse_option_hashref($item);
    }
    elsif ( reftype($item) eq 'ARRAY' ) {
        return {
            value                => $item->[0],
            label                => $item->[1],
            attributes           => {},
            container_attributes => {},
            label_attributes     => {},
        };
    }
    else {
        croak "each options argument must be a hash-ref or array-ref";
    }
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

    if ( !exists $item->{container_attributes} ) {
        $item->{container_attributes}
            = exists $item->{container_attrs}
            ? $item->{container_attrs}
            : {};
    }

    if ( exists $item->{container_attributes_xml} ) {
        for my $key ( keys %{ $item->{container_attributes_xml} } ) {
            $item->{container_attributes}{$key}
                = literal( $item->{container_attributes_xml}{$key} );
        }
    }
    elsif ( exists $item->{container_attrs_xml} ) {
        for my $key ( keys %{ $item->{container_attrs_xml} } ) {
            $item->{container_attributes}{$key}
                = literal( $item->{container_attrs_xml}{$key} );
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
        croak "values argument must be an array-ref"
            if reftype($arg) ne 'ARRAY';

        @values = @$arg;
    }

    my @new = map { {
            value                => $_,
            label                => ucfirst $_,
            attributes           => {},
            container_attributes => {},
            label_attributes     => {},
        }
    } @values;

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
        croak "value_range argument must be an array-ref"
            if reftype($arg) ne 'ARRAY';

        @values = @$arg;
    }

    croak "range must contain at least 2 values" if @values < 2;

    my $end   = pop @values;
    my $start = pop @values;

    return $self->values( [ @values, $start .. $end ] );
}

before prepare_attrs => sub {
    my ( $self, $render ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;

    my $value
        = defined $self->name
        ? $self->get_nested_hash_value( $self->form->input, $self->nested_name )
        : undef;

    if ( ( reftype($value) || '' ) eq 'ARRAY' ) {
        my $elems
            = $self->form->get_fields( { nested_name => $self->nested_name } );
        if ($#$elems) {

            # There are multiple fields with the same name; assume
            # none are multi-value fields, i.e. only one selected
            # option per field.  (Otherwise it might be ambiguous
            # which option came from which field.)
            for ( 0 .. @$elems - 1 ) {
                if ( $self == $elems->[$_] ) {

                    # Use the value of the option actually selected in
                    # this group.
                    $value = $value->[$_];
                }
            }
        }
    }

    if ( !$submitted && defined $default ) {
        for my $deflator ( @{ $self->_deflators } ) {
            $default = $deflator->process($default);
        }
    }

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

    return;
};

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            options => Clone::clone( $self->_options ),
            $args ? %$args : (),
        } );

    $self->_quote_options( $render->{options} );

    return $render;
};

sub _quote_options {
    my ( $self, $options ) = @_;

    foreach my $opt (@$options) {
        $opt->{label}            = xml_escape( $opt->{label} );
        $opt->{value}            = xml_escape( $opt->{value} );
        $opt->{attributes}       = xml_escape( $opt->{attributes} );
        $opt->{label_attributes} = xml_escape( $opt->{label_attributes} );
        $opt->{container_attributes}
            = xml_escape( $opt->{container_attributes} );

        if ( exists $opt->{group} ) {
            $self->_quote_options( $opt->{group} );
        }
    }
}

around clone => sub {
    my ( $orig, $self ) = @_;

    my $clone = $self->$orig(@_);

    $clone->_options( Clone::clone( $self->_options ) );

    return $clone;
};

1;

__END__

=head1 NAME

HTML::FormFu::Role::Element::Group - Role for grouped form fields

=head1 DESCRIPTION

Base class for L<HTML::FormFu::Element::Checkboxgroup>,
L<HTML::FormFu::Element::Radiogroup>, and 
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

Its arguments must be an array-ref of items. Each item may be an array ref 
of the form C<[ $value, $label ]> or a hash-ref of the form 
C<< { value => $value, label => $label } >>. Each hash-ref may also have an
C<attributes> key.

Passing an item containing a C<group> key will, for 
L<Select fields|HTML::FormFu::Element::Select>, create an optgroup. And for 
L<Radiogroup fields|HTML::FormFu::Element::Radiogroup> or
L<Checkboxgroup fields|HTML::FormFu::Element::Checkboxgroup>, create a
sub-group of radiobuttons or checkboxes with a new C<span> block, with the
classname C<subgroup>.

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

C<container_attributes> or C<container_attributes_xml> is used by 
L<HTML::FormFu::Element::Checkboxgroup> and 
L<HTML::FormFu::Element::Radiogroup> for the c<span> surrounding each
item's input and label. It is ignored by L<HTML::FormFu::Element::Select>
elements.

C<label_attributes> / C<label_attributes_xml> is used by 
L<HTML::FormFu::Element::Checkboxgroup> and 
L<HTML::FormFu::Element::Radiogroup> for the c<label> tag of each item.
It is ignored by L<HTML::FormFu::Element::Select> elements.

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

Its arguments must be an array-ref of values. The labels used are the 
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
preceding values are used literally, allowing the common empty first item
in select menus.

=head2 empty_first

If true, then a blank option will be inserted at the start of the option list
(regardless of whether L</options>, L</values> or L</value_range> was used to
populate the options).  See also L</empty_first_label>.

=head2 empty_first_label

=head2 empty_first_label_xml

=head2 empty_first_label_loc

If L</empty_first> is true, and L</empty_first_label> is set, this value will
be used as the label for the first option - so only the first option's value
will be empty.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Field>, L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
