package HTML::FormFu::UploadParam;

use strict;
use Carp qw( croak );

#use HTML::FormFu::ObjectUtil qw( form parent populate );
#use Scalar::Util qw/ weaken /;
use File::Temp qw( tempfile );
use Storable qw/ nfreeze thaw /;

sub new {
    my ( $class, $value ) = @_;

    croak "new() only accepts a single \$value argument"
        if @_ != 2;

    return bless { _value => $value }, $class;
}

sub value {
    my $self = shift;
    
    croak "cannot use value() as a setter" if @_;
    
    return $self->{_value};
}

sub STORABLE_freeze {
    my ( $obj, $cloning ) = @_;

    return if $cloning;

    my $fh = $obj->{_value};
    
    seek $fh, 0, 0;
    
    local $\ = undef;
    my $data = <$fh>;
    
    return nfreeze({ _value => $data });
}

sub STORABLE_thaw {
    my ( $obj, $cloning, $serialized ) = @_;

    return if $cloning;

    my $data = thaw($serialized);

    my ($fh) = tempfile();

    print $fh $data->{_value};

    seek $fh, 0, 0;

    $obj->{_value} = $fh;
    
    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::UploadParam

=head1 DESCRIPTION

=head1 SEE ALSO

L<HTML::FormFu::FormFu>, L<HTML::FormFu::Upload>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
