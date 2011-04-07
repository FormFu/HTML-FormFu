package HTML::FormFu::Element::Search;
use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

after BUILD => sub {
    my $self = shift;

    $self->field_type('search');

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Search - Search form field

=head1 SYNOPSIS

    my $element = $form->element( Search => 'foo' );

=head1 DESCRIPTION

HTML5 search form field.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>.

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>,
Peter Oliver C<cpan.org@mavit.org.uk>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
