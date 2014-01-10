package HTML::FormFu::Role::Element::Input;
use Moose::Role;
use MooseX::SetOnce;

with 'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::FieldMethods' =>
    { -excludes => 'nested_name' },
    'HTML::FormFu::Role::Element::Coercible';

use HTML::FormFu::Util qw( literal xml_escape );
use Clone ();
use List::MoreUtils qw( none );
use Scalar::Util qw( reftype );
use Carp qw( croak );

use HTML::FormFu::Attribute qw(
    mk_attr_accessors
    mk_attr_bool_accessors
);
use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( process_attrs xml_escape );

has field_type => (
    is => 'rw',

    #traits   => ['SetOnce'],
);

has datalist_id => ( is => 'rw' );

has _datalist_options => (
    is      => 'rw',
    default => sub { [] },
    lazy    => 1,
    isa     => 'ArrayRef',
);

__PACKAGE__->mk_attr_accessors(qw(
    alt         autocomplete
    checked     maxlength
    pattern     placeholder
    size
));

__PACKAGE__->mk_attr_bool_accessors(qw(
    autofocus
    multiple
    required
));

my @ALLOWED_OPTION_KEYS = qw(
    value
    value_xml
    value_loc
    label
    label_xml
    label_loc
);

sub datalist_options {
    my ( $self, $arg ) = @_;
    my ( @options, @new );

    return $self->_datalist_options if @_ == 1;

    croak "datalist_options argument must be a single array-ref" if @_ > 2;

    if ( defined $arg ) {
        croak "datalist_options argument must be an array-ref"
            if reftype($arg) ne 'ARRAY';

        @options = @$arg;

        for my $item (@options) {
            push @new, $self->_parse_option($item);
        }
    }

    $self->_datalist_options( \@new );

    return $self;
}

sub _parse_option {
    my ( $self, $item ) = @_;

    if ( reftype($item) eq 'HASH' ) {
        return $self->_parse_option_hashref($item);
    }
    elsif ( reftype($item) eq 'ARRAY' ) {
        return {
            value => $item->[0],
            label => $item->[1],
        };
    }
    else {
        croak "each datalist_options argument must be a hash-ref or array-ref";
    }
}

sub _parse_option_hashref {
    my ( $self, $item ) = @_;

    # sanity check options
    my @keys = keys %$item;

    for my $key (@keys) {
        croak "unknown option argument: '$key'"
            if none { $key eq $_ } @ALLOWED_OPTION_KEYS;
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

sub datalist_values {
    my ( $self, $arg ) = @_;

    croak "datalist_values argument must be a single array-ref of values" if @_ > 2;

    my @values;

    if ( defined $arg ) {
        croak "datalist_values argument must be an array-ref"
            if reftype($arg) ne 'ARRAY';

        @values = @$arg;
    }

    my @new = map { {
            value => $_,
            label => ucfirst $_,
        }
    } @values;

    $self->_datalist_options( \@new );

    return $self;
}

around prepare_id => sub {
    my ( $orig, $self, $render ) = @_;

    $self->$orig($render);

    return if ! @{ $self->_datalist_options };

    if ( defined $render->{datalist_id} ) {
        $render->{attributes}{list} = $render->{datalist_id};
    }
    elsif ( defined $self->auto_datalist_id
        && length $self->auto_datalist_id )
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

        my $id = $self->auto_datalist_id;
        $id =~ s/%([fn])/$string{$1}/g;

        if ( defined( my $count = $self->repeatable_count ) ) {
            $id =~ s/%r/$count/g;
        }

        $render->{attributes}{list} = $id;
    }
    else {
        croak "either 'datalist_id' or 'auto_datalist_id' must be set when using a datalist";
    }

    return;
};

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            field_type  => $self->field_type,
            placeholder => $self->placeholder,
            error_attributes           => xml_escape( $self->error_attributes ),
            error_container_attributes => xml_escape( $self->error_attributes ),
            $args ? %$args : (),
        } );

    if ( @{ $self->_datalist_options } ) {
        $render->{datalist_options} = Clone::clone( $self->_datalist_options );
    }

    $self->_quote_options( $render->{datalist_options} );

    return $render;
};

sub _quote_options {
    my ( $self, $options ) = @_;

    foreach my $opt (@$options) {
        $opt->{label} = xml_escape( $opt->{label} );
        $opt->{value} = xml_escape( $opt->{value} );
    }
}

sub _string_field {
    my ( $self, $render ) = @_;

    my $html = "";
    
    if ( $render->{datalist_options} ) {
        $html .= sprintf qq{<datalist id="%s">\n}, $render->{attributes}{list};
        for my $option ( @{ $render->{datalist_options} } ) {
            $html .= sprintf qq{<option value="%s">%s</option>\n},
                $option->{value},
                $option->{label};
        }
        $html .= sprintf qq{</datalist>\n};
    }
    
    $html .= "<input";

    if ( defined $render->{nested_name} ) {
        $html .= sprintf qq{ name="%s"}, $render->{nested_name};
    }

    $html .= sprintf qq{ type="%s"}, $render->{field_type};

    if ( defined $render->{value} ) {
        $html .= sprintf qq{ value="%s"}, $render->{value};
    }

    $html .= sprintf "%s />", process_attrs( $render->{attributes} );

    return $html;
}

around clone => sub {
    my ( $orig, $self ) = @_;

    my $clone = $self->$orig(@_);

    $clone->_datalist_options( Clone::clone( $self->_datalist_options ) );

    return $clone;
};

1;

__END__

=head1 NAME

HTML::FormFu::Role::Element::Input - Role for input fields

=head1 DESCRIPTION

Base-class for L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::Checkbox>, 
L<HTML::FormFu::Element::File>, 
L<HTML::FormFu::Element::Hidden>, 
L<HTML::FormFu::Element::Password>, 
L<HTML::FormFu::Element::Radio>, 
L<HTML::FormFu::Element::Text>.

=head1 METHODS

=head2 datalist_options

Arguments: none

Arguments: \@options

Use either L</datalist_options> or L</datalist_values> to generate a 
HTML5-compatible C<datalist> group of C<option> tags. This will be associated
with the C<input> element via a C<list> attribute on the C<input> tag.

The C<datalist> ID attribute B<must> be set using either L</datalist_id>
or L</auto_datalist_id>.

    ---
    elements:
      - type: Text
        name: foo
        options:
          - [ 01, January ]
          - [ 02, February ]
          - [ 03, March ]
          - [ 04, April ]

The syntax is similar to L<HTML::FormFu::Role::Element::Group/options>,
except hash-ref items only accept C<value> and C<label> keys (and their variants).

If passed no arguments, it returns an arrayref of the currently set datalist options.

Its arguments must be an array-ref of items. Each item may be an array ref 
of the form C<[ $value, $label ]> or a hash-ref of the form 
C<< { value => $value, label => $label } >>.

When using the hash-ref construct, the C<label_xml> and C<label_loc> 
variants of C<label> are supported, as are the C<value_xml> and C<value_loc> 
variants of C<value>.

=head2 datalist_values

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

A more concise alternative to L</datalist_options>.

Its arguments must be an array-ref of values. The labels used are the 
result of C<ucfirst($value)>.

=head2 datalist_id

Arguments: [$string]

Sets the C<datalist> ID attribute, and automatically sets this C<input> element's
C<list> ID to the same.

Either L</datalist_id> or L</auto_datalist_id> is required,
if either L</datalist_options> or L</datalist_values> are set.

=head2 auto_datalist_id

See L<HTML::FormFu/auto_datalist_id> for details.

=head1 ATTRIBUTE ACCESSORS

Get / set input attributes directly with these methods.

Arguments: [$string]

Return Value: $string

=head2 alt

=head2 autocomplete

=head2 checked

=head2 maxlength

=head2 pattern

=head2 placeholder

=head2 size

=head1 BOOLEAN ATTRIBUTE ACCESSORS

Arguments: [$bool]

Return Value: $self
Return Value: $string
Return Value: undef

Get / set boolean XHTML attributes such as C<required="required">.

If given any true argument, the attribute value will be set equal to the attribute
key name. E.g. C<< $element->required(1) >> will set the attribute C<< required="required" >>.

If given a false argument, the attribute key will be deleted.

When used as a setter, the return value is C<< $self >> to allow chaining.

=head2 autofocus

=head2 multiple

=head2 required

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
