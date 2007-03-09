package HTML::FormFu::Constraint::CallbackOnce;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_accessors(qw/ callback /);

sub process {
    my ( $self, $form_result, $params ) = @_;

    my $name = $self->name;

    my $value = $params->{$name};

    my $callback = $self->callback || sub {1};

    my $ok = $callback->( $value, $params );

    $ok = $self->not ? !$ok : $ok;

    my @errors;

    push @errors, $self->error( { name => $name } )
        if !$ok;

    return \@errors;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::CallbackOnce - CallbackOnce constraint

=head1 SYNOPSIS

    $form->constraint( CallbackOnce => 'foo' )->callback(
        sub {
            my ($params) = @_;
            # do something, return 1 or 0
        }
    );

=head1 DESCRIPTION

Unlinke the L<HTML::FormFu::Constraint::Callback>, this callback is only 
called once for each named field, regardless of how many values are 
submitted.

The argument passed to the callback is a hashref of name/value pairs, 
containing only the applicable named fields. 

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
