package HTML::FormFu::Filter::Encode;

use strict;
use base qw(HTML::FormFu::Filter);

use Encode qw(encode decode FB_CROAK);

__PACKAGE__->mk_accessors($_) for qw(_candidates encode_to);

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    my $utf8 = $self->decode_to_utf8($value);

    if ( !defined $utf8 ) {
        die
            "HTML::FormFu::Filter::Encode: Unable to decode given string to utf8.";
    }

    return $self->encode_from_utf8($utf8);
}

sub get_candidates {
    my $self = shift;
    my $ret  = $self->_candidates;
    if ( $ret && wantarray ) {
        return @$ret;
    }
    return $ret;
}

sub candidates {
    my $self = shift;
    if (@_) {
        if ( ref $_[0] && ref $_[0] eq 'ARRAY' ) {
            $self->_candidates( $_[0] );
        }
        else {
            $self->_candidates( [@_] );
        }
    }
    return $self;
}

sub decode_to_utf8 {
    my ( $self, $value ) = @_;

    my $ret;
    foreach my $candidate ( $self->get_candidates ) {
        eval { $ret = decode( $candidate, $value, FB_CROAK ) };
        if ( !$@ ) {
            last;
        }
    }

    return $ret;
}

sub encode_from_utf8 {
    my ( $self, $value ) = @_;

    my $enc = $self->encode_to;

    if ( !$enc ) {
        return $value;
    }

    return encode( $enc, $value );
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Encode - Encode/Decode Submitted Values

=head1 SYNOPSIS

   # in your config:
   elements:
      - type: text
        filters:
           - type: Encode
             candidates:
                - utf8
                - Hebrew

   # if you want to encode the decoded string to something else
   elements:
      - type: text
        filters:
           - type: Encode
             candidates:
                - utf8
                - Hebrew
             encode_to: UTF-32BE

=head1 AUTHOR

Copyright (c) 2007 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>
All rights reserved.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
