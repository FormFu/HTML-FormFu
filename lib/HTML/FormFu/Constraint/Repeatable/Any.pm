package HTML::FormFu::Constraint::Repeatable::Any;

use strict;
use base 'HTML::FormFu::Constraint';
use Class::C3;

use Scalar::Util qw( reftype );
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

    my $original_name = $field->original_name;

    my @fields =
        grep { $_->get_parent({ type => 'Repeatable' }) == $repeatable }
        grep { $_->original_name eq $original_name }
            @{ $repeatable->get_fields };

    my $increment_field_names = $repeatable->increment_field_names;

    for my $f (@fields) {
        my $value;
        
        if ( $increment_field_names )  {
            $value = $self->get_nested_hash_value( $params, $f->nested_name );
        }
        else {
            $value = _find_this_field_value( $self, $f, $repeatable, $params );
        }

        my $ok = eval { $self->constrain_value($value) };

        if ( $ok && !$@ ) {
            $pass = 1;
            last;
        }
    }

    return $self->mk_errors( {
            pass => $pass,
        } );
}

sub _find_this_field_value {
    my ( $self, $field, $repeatable, $params ) = @_;

    my $nested_name = $field->nested_name;

    my $value = $self->get_nested_hash_value( $params, $nested_name );

    my @fields_with_this_name = @{ $repeatable->get_fields({ nested_name => $nested_name }) };
    
    if ( @fields_with_this_name > 1 ) {
        my $index;
        
        for ( my $i=0; $i <= $#fields_with_this_name; ++$i ) {
            if ( $fields_with_this_name[$i] eq $field ) {
                $index = $i;
                last;
            }
        }
        
        croak 'did not find ourself - how can this happen?'
            if !defined $index;
        
        if ( reftype($value) eq 'ARRAY' ) {
            $value = $value->[$index];
        }
        elsif ( $index == 0 ) {
            # keep $value
        }
        else {
            undef $value;
        }
    }
    
    return $value;
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return defined $value && length $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Repeatable::Any - Ensure at least 1 of a repeated field is filled-in

=head1 SYNOPSIS

    elements:
      - type: Repeatable
        elements:
          - name: foo
            constraints:
              - type: Repeatable::Any

=head1 DESCRIPTION

Ensure at least 1 of a repeated field is filled-in.

Any error will be attached to the first repetition of the field.

This constraint doesn't honour the C<not()> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
