package HTML::FormFu::Element::Select;

use Moose;
extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Group';

use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( append_xml_attribute process_attrs );
use List::MoreUtils qw( any );

__PACKAGE__->mk_attr_accessors(qw( multiple size ));

after BUILD => sub {
    my $self = shift;

    $self->layout_field_filename('field_layout_select_field');
    $self->multi_value(1);

    return;
};

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if (   $submitted
        && defined $value
        && (ref $value eq 'ARRAY'
            ? any { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq $EMPTY_STR )
        && defined( $self->value )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted) {
        delete $option->{attributes}{selected};
    }
    elsif (
        defined $default
        && (ref $default eq 'ARRAY'
            ? any { $_ eq $option->{value} } @$default
            : $default eq $option->{value} ) )
    {
        $option->{attributes}{selected} = 'selected';
    }
    return;
}

sub _string_field {
    my ( $self, $render ) = @_;

    # select_tag template

    my $html .= sprintf qq{<select name="%s"%s>\n},
        $render->{nested_name},
        process_attrs( $render->{attributes} );

    for my $option ( @{ $render->{options} } ) {
        if ( exists $option->{group} ) {
            $html .= "<optgroup";

            if ( defined $option->{label} ) {
                $html .= sprintf qq{ label="%s"}, $option->{label};
            }

            $html .= sprintf "%s>\n", process_attrs( $option->{attributes} );

            for my $item ( @{ $option->{group} } ) {
                $html .= sprintf qq{<option value="%s"%s>%s</option>\n},
                    $item->{value},
                    process_attrs( $item->{attributes} ),
                    $item->{label},
                    ;
            }

            $html .= "</optgroup>\n";
        }
        else {
            $html .= sprintf qq{<option value="%s"%s>%s</option>\n},
                $option->{value},
                process_attrs( $option->{attributes} ),
                $option->{label},
                ;
        }
    }

    $html .= "</select>";

    return $html;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Select - Select form field

=head1 SYNOPSIS

YAML config:

    ---
    elements:
      - type: Select
        name: sex
        options:
          - [ 'm', 'Male' ]
          - [ 'f', 'Female' ]

=head1 DESCRIPTION

Select form field.

Supports optgroups, see L<HTML::FormFu::Role::Element::Group/options> for 
details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Role::Element::Group/options>.

=head2 values

See L<HTML::FormFu::Role::Element::Group/values>.

=head2 value_range

See L<HTML::FormFu::Role::Element::Group/value_range>.

=head2 empty_first

See L<HTML::FormFu::Role::Element::Group/empty_first>.

=head2 empty_first_label

See L<HTML::FormFu::Role::Element::Group/empty_first_label>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Group>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
