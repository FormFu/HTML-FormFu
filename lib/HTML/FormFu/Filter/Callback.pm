package HTML::FormFu::Filter::Callback;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_item_accessors( qw( callback ) );

sub filter {
    my ( $self, $value, $params ) = @_;

    my $callback = $self->callback || sub {$value};

    no strict 'refs';

    return $callback->( $value, $params );
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Callback - filter with custom subroutine

=head1 SYNOPSIS

    $field->filter({
        type     => 'Callback',
        callback => \&my_filter,
    });

    ---
    elements:
      - type: Text
        name: foo
        filters:
          - type: Callback
            callback: "main::my_filter"

    sub my_filter {
        my ($value) = @_;
        
        # do something to $value
        
        return $value;
    }

=head1 DESCRIPTION

Filter using a user-provided subroutine.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::Callback>, by 
Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
