package HTML::FormFu::Constraint::AutoSet;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint::Set';

sub process {
    my $self = shift;
    
    $self->set( map { $_->{value} } @{ $self->parent->_options } );
    
    return $self->SUPER::process(@_);
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::AutoSet

=head1 DESCRIPTION

For use with L<HTML::FormFu::Element::radiogroup> and 
L<HTML::FormFu::Element::select> only.

Ensures that the input value is one of the pre-defined element options.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Set>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
