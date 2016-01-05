package HTML::FormFu::Constraint::DependOn;

use Moose;
extends 'HTML::FormFu::Constraint';

with 'HTML::FormFu::Role::Constraint::Others';

use HTML::FormFu::Util qw(
    DEBUG_CONSTRAINTS
    debug
);

sub process {
    my ( $self, $params ) = @_;

    # check when condition
    if ( !$self->_process_when($params) ) {
        DEBUG_CONSTRAINTS && debug('fail when() check - skipping constraint');
        return;
    }

    my $others = $self->others;
    if ( !defined $others ) {
        DEBUG_CONSTRAINTS && debug('no others() - skipping constraint');
        return;
    }

    my @names = ref $others ? @{$others} : ($others);
    my @failed;

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    if ( !$self->constrain_value($value) ) {
        DEBUG_CONSTRAINTS && debug('no value - skipping constraint');
        return;
    }

    for my $name (@names) {
        my $value = $self->get_nested_hash_value( $params, $name );

        my $ok = 0;

        if ( ref $value eq 'ARRAY' ) {
            my @err = eval { $self->constrain_values( $value, $params ) };
            $ok = 1 if !@err && !$@;
        }
        else {
            $ok = eval { $self->constrain_value($value) };
            $ok = 0 if $@;
        }

        if ( !$ok ) {
            push @failed, $name;
        }
    }

    return $self->mk_errors( {
            pass => @failed ? 0 : 1,
            failed => \@failed,
            names  => [ $self->nested_name, @names ],
        } );
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

sub _localize_args {
    my ($self) = @_;

    return $self->parent->label;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::DependOn - Multi-field Dependency Constraint

=head1 SYNOPSIS

    type: DependOn
    name: foo
    others: bar

=head1 DESCRIPTION

If a value is submitted for the field this constraint is attached to, then a 
value must also be submitted for all fields named in
L<HTML::FormFu::Role::Constraint::Others/others>.

By default, if any of the named fields in
L<HTML::FormFu::Role::Constraint::Others/others> are missing, an error will be
attached to each missing field. This behaviour can be changed by setting
any of L<HTML::FormFu::Role::Constraint::Others/attach_errors_to_base>,
L<HTML::FormFu::Role::Constraint::Others/attach_errors_to_others> or 
L<HTML::FormFu::Role::Constraint::Others/attach_errors_to>.

This constraint doesn't honour the C<not()> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Role::Constraint::Others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
