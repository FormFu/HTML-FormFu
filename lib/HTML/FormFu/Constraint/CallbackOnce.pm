package HTML::FormFu::Constraint::CallbackOnce;

use strict;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_item_accessors(qw( callback ));

sub process {
    my ( $self, $params ) = @_;

    # check when condition
    return if !$self->_process_when($params);

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    my $callback = $self->callback || sub {1};

    no strict 'refs';

    my $ok = eval { $callback->( $value, $params ) };

    return $self->mk_errors( {
            pass => ( $@ or !$ok ) ? 0 : 1,
            message => $@,
        } );
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::CallbackOnce - Code Callback Constraint

=head1 SYNOPSIS

    $form->constraint({
        type => 'CallbackOnce',
        name => 'foo',
        callback => \&sfoo,
    );
    
    sub foo {
        my ( $value, $params ) = @_;

        # return true or false
    }

=head1 DESCRIPTION

Unlinke the L<HTML::FormFu::Constraint::Callback>, this callback is only 
called once, regardless of how many values are submitted.

The first argument passed to the callback is the submitted value for the 
associated field; this may be a single value or an arrayref of value.
The second argument passed to the callback is a hashref of name/value pairs 
for all input fields.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 callback

Arguments: \&sub_ref

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
