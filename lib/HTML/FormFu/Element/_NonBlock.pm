package HTML::FormFu::Element::_NonBlock;

use strict;
use base 'HTML::FormFu::Element';
use Class::C3;

use HTML::FormFu::Util qw( process_attrs );

__PACKAGE__->mk_item_accessors(qw( tag ));

sub new {
    my $self = shift->next::method(@_);

    $self->filename('non_block');

    return $self;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->next::method( {
            tag => $self->tag,
            $args ? %$args : (),
        } );

    return $render;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    # non_block template

    my $html = sprintf "<%s%s />",
        $render->{tag},
        process_attrs( $render->{attributes} ),
        ;

    return $html;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::_NonBlock - base class for single-tag elements

=head1 DESCRIPTION

Base class for single-tag elements.

=head1 METHODS

=head2 tag

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
