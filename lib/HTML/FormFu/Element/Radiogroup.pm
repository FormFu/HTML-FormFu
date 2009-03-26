package HTML::FormFu::Element::Radiogroup;

use strict;
use base 'HTML::FormFu::Element::Checkboxgroup';
use Class::C3;

use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( append_xml_attribute process_attrs );

__PACKAGE__->mk_item_accessors(qw( radiogroup_filename ));

sub new {
    my $self = shift->next::method(@_);

    $self->input_type('radio');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Radiogroup - Group of radiobutton form fields

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
create RadioGroup sub-groups, see L<HTML::FormFu::Element::_Group/options> 
for details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Element::_Group/options>.

=head2 values

See L<HTML::FormFu::Element::_Group/values>.

=head2 value_range

See L<HTML::FormFu::Element::_Group/value_range>.

=head2 empty_first

See L<HTML::FormFu::Element::_Group/empty_first>.

=head2 auto_id

In addition to the substitutions documented by L<HTML::FormFu/auto_id>, 
C<%c> will be replaced by an incremented integer, to ensure there are 
no duplicated ID's.

    ---
    elements:
      type: Radiogroup
      name: foo
      auto_id: "%n_%c"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Checkboxgroup>, 
L<HTML::FormFu::Element::_Group>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
