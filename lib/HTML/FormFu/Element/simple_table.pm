package HTML::FormFu::Element::simple_table;

use strict;
use warnings;
use base 'HTML::FormFu::Element::block';

use HTML::FormFu::Util qw/ append_xml_attribute /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ headers /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->tag('table');

    return $self;
}

sub _add_headers {
    my ($self) = @_;

    my $headers = $self->headers;
    
    return if !$headers || !@$headers;    
    
    eval {
        my @foo = @$headers;
    };
    croak "headers must be passed as an array-ref" if $@;
    
    my @original_rows = @{ $self->_elements };
    $self->_elements([]);
    
    my $header_row = $self->element('block');
    $header_row->tag('tr');
    
    for my $text ( @$headers ) {
        my $th = $header_row->element('block');
        $th->tag('th');
        $th->content($text);
    }
    
    if (@original_rows) {
        push @{ $self->_elements }, @original_rows;
    }
    
    return;
}

sub rows {
    my ( $self, $rows ) = @_;
    
    croak "too many arguments" if @_ > 2;
    
    eval {
        my @foo = @$rows;
    };
    croak "rows must be passed as an array-ref" if $@;
    
    for my $cells (@$rows) {
        my @cells;
        eval {
            @cells = @$cells;
        };
        croak "each row must be an array-ref" if $@;
        
        my $row = $self->element('block');
        $row->tag('tr');
        
        for my $cell (@cells) {
            my $td = $row->element('block');
            $td->tag('td');
            $td->element($cell);
        }
    }
    
    return $self;
}

sub render {
    my $self = shift;
    
    my $copy = $self->clone;
    
    $copy->_add_headers;

    my $render = $copy->SUPER::render({
        @_ ? %{$_[0]} : ()
        });

    append_xml_attribute( $render->attributes, 'class', $self->element_type );

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::simple_table

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
