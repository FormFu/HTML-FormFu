package HTML::FormFu::Filter::CompoundJoin;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ join field_order /);

sub filter {
    my ( $self, $value ) = @_;

    return unless defined $value && $value ne "";
    
    my $join = $self->join;
    $join = ' ' if !defined $join;
    
    my ( $multi, @fields ) = @{ $self->parent->get_fields };
    
    if ( defined ( my $order = $self->field_order ) ) {
        die "not yet implemented";
    }
    else {
        my @names = map { $_->name } @fields;
        
        $value = join $join, map { defined $_ ? $_ : '' } @{$value}{@names};
    }
    
    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::CompoundJoin

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
