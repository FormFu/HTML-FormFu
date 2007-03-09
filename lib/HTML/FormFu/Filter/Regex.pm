package HTML::FormFu::Filter::Regex;

use strict;
use warnings;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ match replace /);

sub filter {
    my ( $self, $value ) = @_;

    my $match   = $self->match;
    my $replace = $self->replace;

    $match   = qr/./ if !defined $match;
    $replace = ''    if !defined $replace;

    $value =~ s/$match/$replace/g;

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Regex - Match/Replace filter

=head1 SYNOPSIS

    $form->filter( Regex => 'foo' )
        ->match( qr/\d/ )
        ->replace( '*' );

=head1 DESCRIPTION

Regex filter.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
