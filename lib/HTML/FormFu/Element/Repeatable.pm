package HTML::FormFu::Element::Repeatable;

use strict;
use base 'HTML::FormFu::Element::Block';
use Class::C3;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(
    qw/ _repeat_count _original_elements increment_field_names /
);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('repeatable');
    $self->_repeat_count(0);

    return $self;
}

sub repeat {
    my ( $self, $count ) = @_;
    
    $count ||= 1;
    
    my $children;
    if ( $self->_original_elements ) {
        $children = $self->_original_elements;
    }
    else {
        $children = $self->_elements;
        $self->_original_elements($children);
        $self->_elements([]);
    }
    
    croak "no child elements to repeat"
        if !@$children;
    
    my $repeat_count = $self->_repeat_count;
    my @return;
    
    for my $rep ( 1 .. $count ) {
        $repeat_count += 1;
        
        my @clones = map { $_->clone } @$children;
        my $block = $self->element('Block');
        
        map { $_->parent($block) } @clones;
        
        $block->_elements(\@clones);
        $block->attributes( $self->attributes );
        $block->tag( $self->tag );
        
        $block->repeatable_count( $repeat_count );
        
        if ( $self->increment_field_names ) {
            for my $field ( @{ $block->get_all_elements } ) {
                next unless $field->is_field;
                my $name = $field->name;
                if ( defined $name && $name =~ /0/ ) {
                    $name =~ s/0/$repeat_count/e;
                    $field->name($name);
                }
            }
        }
        
        push @return, $block;
        
    }
    
    $self->_repeat_count($repeat_count);
    
    return @return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Fieldset - Fieldset element

=head1 SYNOPSIS

    my $fs = $form->element( Fieldset => 'address' );

=head1 DESCRIPTION

Fieldset element.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
