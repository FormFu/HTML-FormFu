package HTML::FormFu::Constraint::DependOn;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint::_others';

sub process {
    my ( $self, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my $first = $self->name;
    my @names = ref $others ? @{$others} : ($others);
    my @failed;

    return if !$self->constrain_value( $params->{$first} );

    for my $name (@names) {
        my $ok = 0;
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            my @err = eval {
                $self->constrain_values( $value, $params );
                };
            $ok = 1 if !@err && !$@;
        }
        else {
            $ok = eval {
                $self->constrain_value($value);
                };
            $ok = 0 if $@;
        }
        
        push @failed, $name
            if !$ok;
    }

    return $self->mk_errors({ 
        pass   => @failed ? 0 : 1,
        failed => \@failed,
        names  => \@names,
    });
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::DependOn

=head1 SYNOPSIS

    type: DependOn
    name: foo
    others: bar

=head1 DESCRIPTION

If a value is submitted for the field this constraint is attached to, then a 
value must also be submitted for all fields named in L</others>.

By default, if any of the named fields in L</others> are missing, an error 
will be attached to each missing field. This behaviour can be changed by 
setting any of L</attach_errors_to_base>, L</attach_errors_to_others> or 
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
