package HTML::FormFu::OutputProcessor::Indent;

use strict;
use base 'HTML::FormFu::OutputProcessor';

use HTML::FormFu::Attribute qw( mk_accessors );
use HTML::FormFu::Constants qw( $EMPTY_STR $SPACE );
use HTML::TokeParser::Simple;
use List::MoreUtils qw( any );

__PACKAGE__->mk_item_accessors( qw( indent ) );

__PACKAGE__->mk_accessors( qw( preserve_tags ) );

sub new {
    my $self = shift->next::method(@_);

    $self->indent       ( "\t" );
    $self->preserve_tags( [qw( pre textarea )] );

    return $self;
}

sub process {
    my ( $self, $input ) = @_;

    my $indent = $self->indent;

    my $parser = HTML::TokeParser::Simple->new( \$input );

    my @preserve_tags = @{ $self->preserve_tags };
    my $count         = 0;
    my $in_pre        = 0;
    my $output        = $EMPTY_STR;

    while ( my $token = $parser->get_token ) {

        if ( $token->is_start_tag ) {
            my $tag = $token->get_tag;

            if ( any { $tag eq $_ } @preserve_tags ) {
                $in_pre = 1;
            }

            $output .= $indent x $count;
            $output .= $token->as_is;

            if ( !defined $token->get_attrseq->[-1]
                 || $token->get_attrseq->[-1] ne "/" )
            {
                $count ++;
            }
        }
        elsif ( $token->is_end_tag ) {
            my $tag = $token->get_tag;

            $count--;

            if ( $output =~ m/ > \s* \z /x && !$in_pre ) {
                $output .= "\n" . $indent x $count;
            }

            if (any { $tag eq $_ } @preserve_tags ) {
                $in_pre = 0;
            }

            $output .= $token->as_is;
        }
        elsif ( $token->is_text ) {
            my $text = $token->as_is;

            if ( length $parser->peek && !$in_pre ) {
                $text =~ s/\A\s+/ /;
                $text =~ s/\s+\z/ /;
            }

            if ( $text eq $SPACE && $parser->peek =~ m/ < /x ) {
                $text = $EMPTY_STR;
            }

            $output .= $text;
        }
        else {
            $output .= $token->as_is;
        }

        if ( $parser->peek =~ m{ < (?!/) }x && !$in_pre ) {
            $output .= "\n";
        }
    }

    return $output;
}

1;

__END__

=head1 NAME

HTML::FormFu::OutputProcessor::Indent - Nicely Indent HTML Output

=head1 SYNOPSIS

    ---
    output_processors:
      - Indent

=head1 METHODS

=head2 indent

Arguments: $string

Default Value: "\t"

The string to be used to indent the HTML.

=head2 preserve_tags

Arguments: \@tags

Default Value: ['pre', 'textarea']

An arrayref of tag names who's contents should not be processed.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::OutputProcessor>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
