package HTML::FormFu::OutputProcessor::StripWhitespace;

use strict;
use base 'HTML::FormFu::OutputProcessor';

use HTML::FormFu::Attribute qw( mk_accessors );
use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::TokeParser::Simple;
use List::MoreUtils qw( any );

__PACKAGE__->mk_accessors( qw(
        collapse_tags
        collapse_consecutive_tags
) );

sub new {
    my $self = shift->next::method(@_);

    $self->collapse_tags( [ qw(
                fieldset
                form
                hr
                legend
                optgroup
                option
                table
                td
                th
                tr
    ) ] );

    $self->collapse_consecutive_tags( [ qw(
                span
                div
    ) ] );

    return $self;
}

sub process {
    my ( $self, $input ) = @_;

    my $parser = HTML::TokeParser::Simple->new( \$input );
    my @tokens;

    while ( my $token = $parser->get_token ) {
        push @tokens, $token;
    }

    my $iter
        = HTML::FormFu::OutputProcessor::StripWhitespace::_iter->new(@tokens);

    my @collapse    = @{ $self->collapse_tags };
    my @consecutive = @{ $self->collapse_consecutive_tags };
    my $output      = $EMPTY_STR;

    while ( defined( my $token = $iter->next ) ) {

        if ( $token->is_start_tag ) {
            my $tag      = $token->get_tag;
            my $prev_tag = $iter->prev_tag_name;

            if ( any { $tag eq $_ } @collapse ) {

                # strip \s from before us
                $output =~ s/ \s+ \z //x;
            }
            elsif ( defined $prev_tag ) {

                # strip \s between <start> <start>
                for my $consec (@consecutive) {
                    if ( $tag eq $consec && $tag eq $prev_tag ) {
                        $output =~ s/ \s+ \z //x;
                    }
                }
            }
        }
        elsif ( $token->is_end_tag ) {
            my $tag      = $token->get_tag;
            my $prev_tag = $iter->prev_tag_name;

            if ( any { $tag eq $_ } @collapse ) {

                # strip \s from before us
                $output =~ s/ \s+ \z //x;
            }
            elsif ( defined $prev_tag ) {

                # strip \s between </end> </end>
                for my $consec (@consecutive) {
                    if ( $tag eq $consec && $tag eq $prev_tag ) {
                        $output =~ s/ \s+ \z //x;
                    }
                }
            }
        }

        my $prev_tag = $iter->prev_tag_name;

        if ( defined $prev_tag && any { $prev_tag eq $_ } @collapse ) {
            $output =~ s/ \s+ \z //x;

            my $part = $token->as_is;

            $part =~ s/ ^ \s+ //x;

            $output .= $part;
        }
        else {
            $output .= $token->as_is;
        }
    }

    return $output;
}

package HTML::FormFu::OutputProcessor::StripWhitespace::_iter;

sub new {
    my ( $class, @tags ) = @_;

    my %self = (
        tags => \@tags,
        i    => 0,
    );

    return bless \%self, $class;
}

sub next {
    my ($self) = @_;

    return $self->{tags}[ $self->{i}++ ];
}

sub prev_tag_name {
    my ($self) = @_;

    my $i = $self->{i} - 2;

    while ( $i >= 0 ) {

        if ( $self->{tags}[$i]->is_tag ) {
            return if !$self->{tags}[$i]->is_tag;

            return $self->{tags}[$i]->get_tag;
        }

        --$i;
    }
}

1;

__END__

=head1 NAME

HTML::FormFu::OutputProcessor::StripWhitespace - Strip shitespace from HTML output

=head1 SYNOPSIS

    ---
    output_processors:
      - StripWhitespace

=head1 METHODS

=head2 collapse_tags

=head2 collapse_consecutive_tags

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::OutputProcessor>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
