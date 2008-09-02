package HTML::FormFu::Inflator;

use strict;
use base 'HTML::FormFu::Processor';
use Class::C3;

use HTML::FormFu::Exception::Inflator;
use Scalar::Util qw( blessed );
use Carp qw( croak );

sub process {
    my ( $self, $values ) = @_;

    my $return;
    my @errors;

    if ( ref $values eq 'ARRAY' ) {
        my @return;
        for my $value (@$values) {
            ($return) = eval { $self->inflator($value) };
            
            if ($@) {
                push @errors, $self->return_error($@);
                push @return, undef;
            }
            else {
                push @return, $return;
            }
        }
        $return = \@return;
    }
    else {
        ($return) = eval { $self->inflator($values) };
        
        if ($@) {
            push @errors, $self->return_error($@);
        }
    }

    return ( $return, @errors );
}

sub return_error {
    my ( $self, $err ) = @_;

    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Inflator') ) {
        $err = HTML::FormFu::Exception::Inflator->new;
    }

    return $err;
}

1;

__END__

=head1 NAME

HTML::FormFu::Inflator - Inflator Base Class

=head1 SYNOPSIS

    my $inflator = $form->inflator( $type, @names );

=head1 DESCRIPTION

Inflator Base Class.

=head1 METHODS

=head2 names

Arguments: @names

Return Value: @names

Contains names of params to inflator.

=head2 process

Arguments: $form_result, \%params

=head1 CORE INFLATORS

=over

=item L<HTML::FormFu::Inflator::CompoundDateTime>

=item L<HTML::FormFu::Inflator::DateTime>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
