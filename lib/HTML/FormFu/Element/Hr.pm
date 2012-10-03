package HTML::FormFu::Element::Hr;
use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::NonBlock';

after BUILD => sub {
    my $self = shift;

    $self->tag('hr');

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Hr - horizontal-rule element

=head1 DESCRIPTION

Horizontal-rule element.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::NonBlock>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
