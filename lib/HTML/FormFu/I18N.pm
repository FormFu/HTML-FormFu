package HTML::FormFu::I18N;
use strict;

use base 'Locale::Maketext';

*loc = \&localize;

sub localize {
    my $self = shift;

    return $self->maketext(@_);
}

1;

__END__

=head1 NAME

HTML::FormFu::I18N - Default localization class

=head1 SYNOPSIS

See L<HTML::FormFu/localize_class>.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter>, by
Sebastian Riedel.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
