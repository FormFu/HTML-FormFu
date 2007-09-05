package HTML::FormFu::Constraint::AllOrNone;

use strict;
use base 'HTML::FormFu::Constraint::_others';

sub process {
    my ( $self, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my @names = ( $self->name );
    push @names, ref $others ? @{$others} : $others;
    my @failed;

    for my $name (@names) {
        my $seen  = 0;
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            my @errors = eval { $self->constrain_values( $value, $params ); };
            $seen = 1 if !@errors && !$@;
        }
        else {
            my $ok = eval { $self->constrain_value($value); };
            $seen = 1 if $ok && !$@;
        }

        push @failed, $name
            if !$seen;
    }

    return $self->mk_errors( {
            pass => @failed && scalar @failed != scalar @names ? 0 : 1,
            failed => \@failed,
            names  => \@names,
        } );
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::AllOrNone - Multi-field All or None Constraint

=head1 SYNOPSIS

    type: AllOrNone
    name: foo
    others: [bar, baz]

=head1 DESCRIPTION

Ensure that either all or none of the named fields are present.

By default, if some but not all fields are submitted, errors are attached to 
those fields which weren't submitted. This behaviour can be changed by setting 
any of L</attach_errors_to_base>, L</attach_errors_to_others> or 
L</attach_errors_to>.

This constraint doesn't honour the C<not()> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Constraint::_others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
