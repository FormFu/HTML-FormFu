package HTML::FormFu::Constraint::Repeatable::Any;

use strict;
use base 'HTML::FormFu::Constraint';
use Class::C3;

use Carp qw( croak );

sub new {
    my $self = shift->next::method(@_);

    $self->only_on_reps([1]);

    return $self;
}

sub process {
    my ( $self, $params ) = @_;

    return unless $self->_run_this_rep;

    # check when condition
    return if !$self->_process_when($params);

    my $field      = $self->field;
    my $repeatable = $field->get_parent({ type => 'Repeatable' });
    my $pass;

    if ( $repeatable->increment_field_names ) {
        my $original_name = $field->original_name;

        my @fields =
            grep { $_->get_parent({ type => 'Repeatable' }) == $repeatable }
            grep { $_->original_name eq $original_name }
                @{ $repeatable->get_fields };
    
        for my $f (@fields) {
            my $value = $self->get_nested_hash_value( $params, $f->nested_name );
    
            my $ok = eval { $self->constrain_value($value) };
    
            if ( $ok && !$@ ) {
                $pass = 1;
                last;
            }
        }
    }
    else {
        my $error = 'not implemented yet for repeatable elements with increment_field_names=0';

        warn $error;
        croak $error;
    }

    return $self->mk_errors( {
            pass => $pass,
        } );
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return defined $value && length $value;
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

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
