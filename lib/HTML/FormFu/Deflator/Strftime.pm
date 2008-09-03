package HTML::FormFu::Deflator::Strftime;

use strict;
use base 'HTML::FormFu::Deflator';

__PACKAGE__->mk_item_accessors( qw( strftime ) );

sub deflator {
    my ( $self, $value ) = @_;

    my $return;

    eval { $return = $value->strftime( $self->strftime ) };

    if ($@) {
        $return = $value;
    }

    return $return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Deflator::Strftime - Strftime deflator

=head1 SYNOPSIS

    $form->deflator( Strftime => 'start_time' )
        ->strftime( '%d/%m/%Y' );

=head1 DESCRIPTION

Strftime deflator for L<DateTime> objects.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
