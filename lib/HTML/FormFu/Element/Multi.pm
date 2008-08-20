package HTML::FormFu::Element::Multi;

use strict;
use base 'HTML::FormFu::Element::Block', 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::Element::_Field qw/ :FIELD /;
use HTML::FormFu::Util
    qw/ append_xml_attribute xml_escape process_attrs _parse_args _get_elements _filter_components /;
use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(
    qw/
        field_filename
        label_filename
        javascript
        container_tag
        label_tag
        /
);

__PACKAGE__->mk_output_accessors(
    qw/
        comment label value
        /
);

__PACKAGE__->mk_attrs(
    qw/
        comment_attributes
        container_attributes
        label_attributes
        /
);

sub new {
    my $self = shift->next::method(@_);

    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->filename('multi');
    $self->label_attributes( {} );
    $self->label_filename('label');
    $self->label_tag('label');

    return $self;
}

sub get_fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my $f = $self->next::method(@_);

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

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->next::method(@_);

    append_xml_attribute( $render->{attributes}, 'class', 'elements' );

    return $render;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data_non_recursive;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # multi template

    $html .= sprintf "<span%s>\n", process_attrs( $render->{attributes} );

    for my $elem ( @{ $self->get_elements } ) {
        my $render = $elem->render_data;

        next if !defined $render;

        if ( $elem->reverse_multi ) {
            $html .= $elem->_string_field($render);

            if ( defined $elem->label ) {
                $html .= "\n" . $elem->_string_label($render);
            }
        }
        else {
            if ( defined $elem->label ) {
                $html .= $elem->_string_label($render) . "\n";
            }

            $html .= $elem->_string_field($render);
        }

        $html .= "\n";
    }

    $html .= "</span>";

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->comment_attributes( dclone $self->comment_attributes );
    $clone->container_attributes( dclone $self->container_attributes );
    $clone->label_attributes( dclone $self->label_attributes );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Multi - Combine multiple fields in a single element

=head1 SYNOPSIS

    my $e = $form->element( Multi => 'foo' );

=head1 DESCRIPTION

Combine multiple form fields in a single logical element.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
