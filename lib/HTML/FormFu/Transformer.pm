package HTML::FormFu::Transformer;

use Moose;
extends 'HTML::FormFu::Processor';

use HTML::FormFu::Exception::Transformer;
use Scalar::Util qw( blessed );

sub process {
    my ( $self, $values, $params ) = @_;

    my $return;
    my @errors;

    if ( ref $values eq 'ARRAY' ) {
        my @return;
        for my $value (@$values) {
            my ($return) = eval { $self->transformer( $value, $params ) };

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
        ($return) = eval { $self->transformer( $values, $params ) };

        if ($@) {
            push @errors, $self->return_error($@);
        }
    }

    $self->set_nested_hash_value( $params, $self->nested_name, $return );

    return (@errors);
}

sub return_error {
    my ( $self, $err ) = @_;

    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Transformer') ) {
        $err = HTML::FormFu::Exception::Transformer->new;
    }

    return $err;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Transformer - Transformer Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 CORE TRANSFORMERS

=over

=item L<HTML::FormFu::Transformer::Callback>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
