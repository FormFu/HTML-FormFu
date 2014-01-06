package HTML::FormFu::Filter::ForceListValue;
use Moose;
extends 'HTML::FormFu::Filter';

sub process {
    my ( $self, $result, $params ) = @_;

    my $name = $self->nested_name;
    my $value = $self->get_nested_hash_value( $params, $name );

    return if 'ARRAY' eq ref $value;

    $self->set_nested_hash_value( $params, $name, [$value] );
};

1;

=head1 NAME

HTML::FormFu::Filter::ForceListValue

=head1 SYNOPSIS

    element:
      - type: Repeatable
        increment_field_names: 0
        elements:
          - name: foo
            render_processed_value: 1
            filter:
              - ForceListValue

=head1 DESCRIPTION

Causes a single submitted value to be changed to a list containing 1 item.

Solves an uncommon problem with a 
L<Repeatable block|HTML::FormFu::Element::Repeatable> with 
L<increment_field_names|HTML::FormFu::Element::Repeatable/increment_field_names>
disabled, when manually increasing the 
L<repeat|HTML::FormFu::Element::Repeatable/repeat> count after the form was
submitted with only a single value for each of the Repeatable's fields.

If these circumstances, when rendered, every repeated field would have the
initially-submitted value as its default.

Using this filter, and setting 
L<render_processed_value|HTML::FormFu/render_processed_value> to C<true> will
ensure that only the first repetition of each field will have the submitted
value as its default; all subsequent repetitions will have no default value.

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
