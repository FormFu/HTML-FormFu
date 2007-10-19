package HTML::FormFu::Element::Radiogroup;

use strict;
use base 'HTML::FormFu::Element::_Group';
use Class::C3;

use HTML::FormFu::Util qw( append_xml_attribute );

__PACKAGE__->mk_accessors(qw/ radiogroup_filename /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('radiogroup');
    $self->radiogroup_filename('radiogroup_tag');
    $self->label_filename('legend');
    $self->container_tag('fieldset');

    return $self;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    my $form_id    = defined $self->form->id ? $self->form->id : '';
    my $field_name = defined $self->name     ? $self->name     : '';
    my $count      = 0;

    for my $option ( @{ $render->{options} } ) {
        if ( exists $option->{group} ) {
            for my $item ( @{ $option->{group} } ) {
                $self->_prepare_id( $item, $form_id, $field_name, \$count );
            }
        }
        else {
            $self->_prepare_id( $option, $form_id, $field_name, \$count );
        }
    }

    return;
}

sub _prepare_id {
    my ( $self, $option, $form_id, $field_name, $count_ref ) = @_;

    if ( !exists $option->{attributes}{id} && defined $self->auto_id ) {
        my %string = (
            f => $form_id,
            n => $field_name,
        );

        my $id = $self->auto_id;
        $id =~ s/%([fn])/$string{$1}/g;
        $id =~ s/%c/ ++$$count_ref /gex;

        $option->{attributes}{id} = $id;
    }

    # label "for" attribute
    if (   exists $option->{label}
        && exists $option->{attributes}{id}
        && !exists $option->{label_attributes}{for} )
    {
        $option->{label_attributes}{for} = $option->{attributes}{id};
    }

    return;
}

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if (   $submitted
        && defined $value
        && (ref $value eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted) {
        delete $option->{attributes}{checked};
    }
    elsif ( defined $default && $default eq $option->{value} ) {
        $option->{attributes}{checked} = 'checked';
    }

    return;
}

sub _render_label {
    my ( $self, $render ) = @_;

    $self->next::method($render);

    if ( defined $render->{label} && $render->{label_filename} eq 'legend' ) {
        $render->{container_attributes}{class} =~ s/\blabel\b/legend/;
    }

    return;
}

sub render {
    my $self = shift;

    my $render = $self->next::method( {
            radiogroup_filename => $self->radiogroup_filename,
            @_ ? %{ $_[0] } : () } );

    for my $item ( @{ $render->{options} } ) {
        append_xml_attribute( $item->{attributes}, 'class', 'subgroup' )
            if exists $item->{group};
    }

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Radiogroup - Group of radiobutton form fields

=head1 SYNOPSIS

YAML config:

    ---
    elements:
      - type: RadioGroup
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
L<HTML::FormFu::Element::_Group>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
