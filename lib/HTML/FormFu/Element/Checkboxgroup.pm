package HTML::FormFu::Element::Checkboxgroup;
use Moose;
use MooseX::Attribute::FormFuChained;
extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Group';

use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( append_xml_attribute process_attrs );
use List::MoreUtils qw( any );

has input_type => (
    is      => 'rw',
    default => 'checkbox',
    lazy    => 1,
    traits  => ['FormFuChained'],
);

has reverse_group => (
    is     => 'rw',
    traits => ['FormFuChained'],
);

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->layout_field_filename('field_layout_checkboxgroup_field');
    $self->label_tag('legend');
    $self->container_tag('fieldset');
    $self->multi_value(1);
    $self->reverse_group(1);
    $self->input_type('checkbox');

    $self->layout( [
        'label',
        'errors',
        'field',
        'comment',
        'javascript',
    ] );

    return;
};

sub prepare_id {
    my ( $self, $render ) = @_;

    my $form_id    = defined $self->form->id    ? $self->form->id    : '';
    my $field_name = defined $self->nested_name ? $self->nested_name : '';
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
        $id =~ s/%v/ $option->{value} /gex;

        if ( defined( my $count = $self->repeatable_count ) ) {
            $id =~ s/%r/$count/g;
        }

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
            ? any { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq $EMPTY_STR )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted) {
        delete $option->{attributes}{checked};
    }
    elsif (
        defined $default
        && (ref $default eq 'ARRAY'
            ? any { $_ eq $option->{value} } @$default
            : $default eq $option->{value} ) )
    {
        $option->{attributes}{checked} = 'checked';
    }
    return;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            field_filename => $self->field_filename,
            reverse_group  => $self->reverse_group,
            input_type     => $self->input_type,
            $args ? %$args : (),
        } );

    for my $item ( @{ $render->{options} } ) {
        if ( exists $item->{group} ) {
            append_xml_attribute( $item->{attributes}, 'class', 'subgroup' );
        }
    }

    return $render;
}

sub _string_field {
    my ( $self, $render ) = @_;

    # radiogroup_tag template

    my $html .= sprintf "<span%s>\n", process_attrs( $render->{attributes} );

    for my $option ( @{ $render->{options} } ) {
        if ( defined $option->{group} ) {
            $html .= sprintf "<span%s>\n",
                process_attrs( $option->{attributes} ),
                ;

            for my $item ( @{ $option->{group} } ) {
                $html .= sprintf
                    "<span%s>\n",
                    process_attrs( $item->{container_attributes} );

                my $label = sprintf
                    "<label%s>%s</label>\n",
                    process_attrs( $item->{label_attributes} ),
                    $item->{label},
                    ;

                my $input = sprintf
                    qq{<input name="%s" type="%s" value="%s"%s />\n},
                    $render->{nested_name},
                    $render->{input_type},
                    $item->{value},
                    process_attrs( $item->{attributes} ),
                    ;

                if ( $render->{reverse_group} ) {
                    $html .= $input . $label;
                }
                else {
                    $html .= $label . $input;
                }

                $html .= "</span>\n";
            }

            $html .= "</span>\n";
        }
        else {
            $html .= sprintf
                "<span%s>\n",
                process_attrs( $option->{container_attributes} );

            my $label = sprintf
                "<label%s>%s</label>\n",
                process_attrs( $option->{label_attributes} ),
                $option->{label},
                ;

            my $input = sprintf
                qq{<input name="%s" type="%s" value="%s"%s />\n},
                $render->{nested_name},
                $render->{input_type},
                $option->{value},
                process_attrs( $option->{attributes} ),
                ;

            if ( $render->{reverse_group} ) {
                $html .= $input . $label;
            }
            else {
                $html .= $label . $input;
            }

            $html .= "</span>\n";
        }
    }

    $html .= "</span>";

    return $html;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Checkboxgroup - Group of checkbox form fields

=head1 SYNOPSIS

YAML config:

    ---
    elements:
      - type: Checkboxgroup
        name: subjects
        options:
          - [ 'Math' ]
          - [ 'Science' ]
          - [ 'English' ]

=head1 DESCRIPTION

Convenient to use group of checkbox fields.

Use the same syntax as you would to create a Select element optgroup to 
create Checkboxgroup sub-groups, see L<HTML::FormFu::Role::Element::Group/options> 
for details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Role::Element::Group/options>.

=head2 values

See L<HTML::FormFu::Role::Element::Group/values>.

=head2 value_range

See L<HTML::FormFu::Role::Element::Group/value_range>.

=head2 auto_id

In addition to the substitutions documented by L<HTML::FormFu/auto_id>, 
C<%c> will be replaced by an incremented integer, to ensure there are 
no duplicated ID's, and C<%v> will be replaced by the item's value to
allow multiple elements with the same name to coexist, and their labels
to correctly select the appropriate item.

    ---
    elements:
      type: Checkboxgroup
      name: foo
      auto_id: "%n_%c"

=head2 reverse_group

If true, then the label for each checkbox in the checkbox group should
be rendered to the right of the field control.  Otherwise, the label
is rendered to the left of the field control.

The default value is C<true>, causing each label to be rendered to the
right of its field control (or to be explicit: the markup for the
label comes after the field control in the source).

Default Value: C<true>

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
