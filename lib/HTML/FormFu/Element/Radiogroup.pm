use strict;

package HTML::FormFu::Element::Radiogroup;

# ABSTRACT: Group of radiobutton form fields

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Element::Checkboxgroup';

use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( append_xml_attribute process_attrs );

after BUILD => sub {
    my $self = shift;

    $self->input_type('radio');

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

YAML config:

    ---
    elements:
      - type: Radiogroup
        name: sex
        options:
          - [ 'm', 'Male' ]
          - [ 'f', 'Female' ]

=head1 DESCRIPTION

Convenient to use group of radio button fields.

Use the same syntax as you would to create a Select element optgroup to
create RadioGroup sub-groups, see L<HTML::FormFu::Role::Element::Group/options>
for details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Role::Element::Group/options>.

=head2 values

See L<HTML::FormFu::Role::Element::Group/values>.

=head2 value_range

See L<HTML::FormFu::Role::Element::Group/value_range>.

=head2 empty_first

See L<HTML::FormFu::Role::Element::Group/empty_first>.

=head2 auto_id

In addition to the substitutions documented by L<HTML::FormFu/auto_id>,
C<%c> will be replaced by an incremented integer, to ensure there are
no duplicated ID's.

    ---
    elements:
      type: Radiogroup
      name: foo
      auto_id: "%n_%c"

=head2 reverse_group

See L<HTML::FormFu::Element::Checkboxgroup/reverse_group>.

=head1 DEPRECATED METHODS

=head2 radiogroup_filename

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Element::Checkboxgroup>,
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
