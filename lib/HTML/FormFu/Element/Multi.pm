use strict;
package HTML::FormFu::Element::Multi;


use Moose;
extends 'HTML::FormFu::Element::Block';

with
    'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::SingleValueField';

use HTML::FormFu::Util
    qw( append_xml_attribute xml_escape process_attrs _parse_args _get_elements _filter_components );
use Clone ();

after BUILD => sub {
    my $self = shift;

    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->label_attributes(     {} );
    $self->layout_field_filename('field_layout_multi_field');
    $self->label_tag('label');

    return;
};

sub get_fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my $f = $self->SUPER::get_fields(@_);

    unshift @$f, $self;

    return _get_elements( \%args, $f );
}

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_deflators };

    push @x, map { @{ $_->get_deflators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_filters };

    push @x, map { @{ $_->get_filters(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_constraints };

    push @x, map { @{ $_->get_constraints(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_inflators };

    push @x, map { @{ $_->get_inflators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_validators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_validators };

    push @x, map { @{ $_->get_validators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_transformers {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_transformers };

    push @x, map { @{ $_->get_transformers(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = @{ $self->_errors };

    push @x, map { @{ $_->get_errors(@_) } } @{ $self->_elements };

    _filter_components( \%args, \@x );

    if ( !$args{forced} ) {
        @x = grep { !$_->forced } @x;
    }

    return \@x;
}

sub clear_errors {
    my ($self) = @_;

    $self->_errors( [] );

    map { $_->clear_errors } @{ $self->_elements };

    return;
}

sub render_data {
    my $self = shift;

    my $render = $self->SUPER::render_data(@_);

    map {
        delete $_->{container_tag}
    } @{ $render->{elements} || [] };

    return $render;
}

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->SUPER::render_data_non_recursive(@_);

    append_xml_attribute( $render->{attributes}, 'class', 'elements' );

    return $render;
}

sub _parse_layout_field {
    my ( $self, $render ) = @_;

    my @html = (
        sprintf "<span%s>", process_attrs( $render->{attributes} ),
    );

    for my $elem ( @{ $self->get_elements } ) {
        my $render = $elem->render_data;

        next if !defined $render;

        $render->{container_tag} = undef;

        push @html, $elem->string( { render_data => $render, layout => $elem->multi_layout } );
    }

    push @html, "</span>";

    return join "\n", @html;
}

sub clone {
    my $self = shift;

    my $clone = $self->SUPER::clone(@_);

    $clone->comment_attributes( Clone::clone( $self->comment_attributes ) );
    $clone->container_attributes( Clone::clone( $self->container_attributes ) );
    $clone->label_attributes( Clone::clone( $self->label_attributes ) );

    return $clone;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Multi - Combine multiple fields in a single element

=head1 SYNOPSIS

    my $e = $form->element( Multi => 'foo' );

=head1 DESCRIPTION

Combine multiple form fields in a single logical element.

Non-field elements cannot be added as children of the Multi element.

=head1 RENDERING NOTES

If the Multi element is rendered with the default 'string' render-method,
all child fields will be rendered with the 'string' render-method, regardless
of their L<HTML::FormFu/render_method> value.

Likewise, if the Multi element is rendered with the 'tt' render-method,
all child fields will be rendered with the 'tt' render-method, regardless of
their L<HTML::FormFu/render_method> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Role::Element::Field>,
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
