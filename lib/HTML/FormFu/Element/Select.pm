package HTML::FormFu::Element::Select;

use strict;
use base 'HTML::FormFu::Element::_Group';
use Class::C3;

use HTML::FormFu::Util qw( append_xml_attribute );

__PACKAGE__->mk_attr_accessors(qw/ multiple size /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('select');
    $self->field_filename('select_tag');
    $self->multi_filename('multi_ltr');

    return $self;
}

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if (   $submitted
        && defined $value
        && (ref $value eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted) {
        delete $option->{attributes}{selected};
    }
    elsif ( defined $default
        && (ref $default eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$default
            : $default eq $option->{value} ) ) {
        $option->{attributes}{selected} = 'selected';
    }
    return;
}

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

Supports optgroups, see L<HTML::FormFu::Element::_Group/options> for 
details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Element::_Group/options>.

=head2 values

See L<HTML::FormFu::Element::_Group/values>.

=head2 value_range

See L<HTML::FormFu::Element::_Group/value_range>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Group>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
