package HTML::FormFu::OutputProcessor::Indent;

use strict;
use base 'HTML::FormFu::OutputProcessor';

use HTML::FormFu::Attribute(qw/ mk_accessors /);
use HTML::TokeParser::Simple;

__PACKAGE__->mk_accessors(qw/ indent preserve_tags /);

sub new {
    my $self = shift->next::method(@_);

    $self->indent("\t");
    $self->preserve_tags( [qw/ pre textarea /] );

    return $self;
}

sub process {
    my ( $self, $input ) = @_;

    my $indent = $self->indent;

    my $parser = HTML::TokeParser::Simple->new( \$input );

    my @preserve_tags = @{ $self->preserve_tags };
    my $count         = 0;
    my $in_pre        = 0;
    my $output        = "";

    while ( my $token = $parser->get_token ) {

        if ( $token->is_start_tag ) {
            my $tag = $token->get_tag;

            $in_pre = 1 if grep { $tag eq $_ } @preserve_tags;

            $output .= $indent x $count;
            $output .= $token->as_is;

            $count++
                unless defined $token->get_attrseq->[-1]
                    && $token->get_attrseq->[-1] eq "/";
        }
        elsif ( $token->is_end_tag ) {
            my $tag = $token->get_tag;

            $count--;

            if ( $output =~ m/ > \s* \z /x && !$in_pre ) {
                $output .= "\n" . $indent x $count;
            }

            $in_pre = 0 if grep { $tag eq $_ } @preserve_tags;

            $output .= $token->as_is;
        }
        elsif ( $token->is_text ) {
            my $text = $token->as_is;

            if ( length $parser->peek && !$in_pre ) {
                $text =~ s/\A\s+/ /;
                $text =~ s/\s+\z/ /;
            }

            if ( $text eq ' ' && $parser->peek =~ m/ < /x ) {
                $text = "";
            }

            $output .= $text;
        }
        else {
            $output .= $token->as_is;
        }

        $output .= "\n" if $parser->peek =~ m{ < (?!/) }x && !$in_pre;
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

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
