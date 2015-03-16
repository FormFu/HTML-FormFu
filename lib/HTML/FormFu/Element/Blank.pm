package HTML::FormFu::Element::Blank;

use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

use HTML::FormFu::Constants qw( $EMPTY_STR );

after BUILD => sub {
    my $self = shift;

    $self->label_tag($EMPTY_STR);

    #$self->field_type( $EMPTY_STR );
    $self->render($EMPTY_STR);

    return;
};

sub field_tag {
    return $EMPTY_STR;
}

override render => sub {
    return $EMPTY_STR;
};

around render_data_non_recursive => sub {
    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Blank - blank element

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Input>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
