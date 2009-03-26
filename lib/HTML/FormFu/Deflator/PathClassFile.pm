package HTML::FormFu::Deflator::PathClassFile;

use strict;
use base 'HTML::FormFu::Deflator';

__PACKAGE__->mk_item_accessors(qw( relative absolute basename ));

sub deflator {
    my ( $self, $value ) = @_;
    return $value unless ( ref $value );

    # we default to relative(1)
    $self->relative(1)
        unless ( $self->absolute || $self->basename || $self->relative );

    if ( $self->relative ) {
        return $value->relative(
            $self->relative eq "1" ? undef : $self->relative )->stringify;
    }
    elsif ( $self->absolute ) {
        return $value->absolute(
            $self->absolute eq "1" ? undef : $self->absolute )->stringify;
    }
    elsif ( $self->basename ) {
        return $value->basename;
    }

    # fallback, should never happen
    return $value->stringify;
}

1;

__END__

=head1 NAME

HTML::FormFu::Deflator::PathClassFile - Deflator for Path::Class::File objects

=head1 SYNOPSIS

    $form->deflator( PathClassFile => 'file' )
        ->relative( 'root' );

    ---
    elements:
        - type: Text
          deflator:
              - type: PathClassFile
                relative: root

=head1 DESCRIPTION

Deflator for Path::Class::File objects.

There are three types of deflation:

=over

=item relative

Set this to 1 to deflate to a relative path. Anything else than 1 specifies the 
directory to use as the base of relativity - otherwise the current working 
directory will be used.

=item absolute

Set this to 1 to deflate to an absolute path. Anything else than 1 specifies the 
directory to use as the base of relativity - otherwise the current working 
directory will be used.

=item basename

Set this to 1 to get the name of the file without the directory portion.

=back

As you cannot set values for a File element, this deflator will only work
on regular form elements.


=head1 AUTHOR

Moritz Onken, C<onken@houseofdesign.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
