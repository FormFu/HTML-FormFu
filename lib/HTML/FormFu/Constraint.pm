package HTML::FormFu::Constraint;

use strict;
use base 'HTML::FormFu::Processor';
use Class::C3;

use HTML::FormFu::Exception::Constraint;
use HTML::FormFu::Util qw(
    DEBUG_CONSTRAINTS
    debug
);
use List::MoreUtils qw( any );
use List::Util qw( first );
use Scalar::Util qw( reftype blessed );
use Storable qw( dclone );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw( only_on_reps ));

__PACKAGE__->mk_item_accessors(qw( not force_errors when ));

sub process {
    my ( $self, $params ) = @_;

    return unless $self->_run_this_rep;

    my $value = $self->_find_field_value( $params );

    my @errors;

    # check when condition
    if ( !$self->_process_when($params) ) {
        DEBUG_CONSTRAINTS && debug('fail when() check - skipping constraint');
        return;
    }

    if ( ref $value eq 'ARRAY' ) {
        push @errors, eval { $self->constrain_values( $value, $params ) };

        if ($@) {
            push @errors,
                $self->mk_errors( {
                    pass    => 0,
                    message => $@,
                } );
        }
    }
    else {
        my $ok = eval { $self->constrain_value( $value, $params ) };

        DEBUG_CONSTRAINTS && debug( 'CONSTRAINT RETURN VALUE' => $ok );
        DEBUG_CONSTRAINTS && debug( '$@' => $@ );

        push @errors,
            $self->mk_errors( {
                pass => ( $@ || !$ok ) ? 0 : 1,
                message => $@,
            } );
    }

    return @errors;
}

sub _run_this_rep {
    my ($self) = @_;
    
    my $only_on_reps = $self->only_on_reps
        or return 1;
    
    my $current_rep = $self->field->repeatable_count
        or return 1;
    
    $only_on_reps = [$only_on_reps]
        if ( reftype($only_on_reps) || '' ) ne 'ARRAY';
    
    return first { $current_rep == $_ } @$only_on_reps;
}

sub _find_field_value {
    my ( $self, $params ) = @_;

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    my @fields_with_this_name = @{ $self->form->get_fields({ nested_name => $self->nested_name }) };
    
    if ( @fields_with_this_name > 1 ) {
        my $field = $self->parent;
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


sub constrain_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval { $self->constrain_value( $value, $params ) };

        DEBUG_CONSTRAINTS && debug( 'CONSTRAINT RETURN VALUE' => $ok );
        DEBUG_CONSTRAINTS && debug( '$@' => $@ );

        push @errors,
            $self->mk_errors( {
                pass => ( $@ || !$ok ) ? 0 : 1,
                message => $@,
            } );
    }

    return @errors;
}

sub constrain_value {
    croak "constrain_value() should be overridden";
}

sub mk_errors {
    my ( $self, $args ) = @_;

    my $pass    = $args->{pass};
    my $message = $args->{message};

    my @errors;
    my $force = $self->force_errors || $self->parent->force_errors;

    if ( !$pass || $force ) {
        my $error = $self->mk_error($message);

        $error->forced(1) if $pass;

        push @errors, $error;
    }

    return @errors;
}

sub mk_error {
    my ( $self, $err ) = @_;

    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Constraint') ) {
        $err = HTML::FormFu::Exception::Constraint->new;
    }

    return $err;
}

sub _process_when {
    my ( $self, $params ) = @_;

    # returns 1 if when condition is fullfilled or not defined
    # returns 0 if when condition is defined and not fullfilled
    # If it's a callback, return callback's return value (so when
    # condition is met if callback returns a true value)

    # get when condition
    my $when = $self->when;
    return 1 if !defined $when;

    # check type of 'when'
    croak "Parameter 'when' is not a hash ref" if ref $when ne 'HASH';

    # field or callback must be defined
    my $when_field    = $when->{field};
    my $when_callback = $when->{callback};
    croak "Parameter 'field' or 'callback' is not defined"
        if !defined $when_field && !defined $when_callback;

    # Callback will be the preferred thing
    if ($when_callback) {
        no strict 'refs';
        return $when_callback->($params);
    }

    # nothing to constrain if field doesn't exist
    my $when_field_value = $self->get_nested_hash_value( $params, $when_field );
    return 0 if !defined $when_field_value;

    my @values;

    if ( defined( my $value = $when->{value} ) ) {
        push @values, $value;
    }
    elsif ( defined( my $values = $when->{values} ) ) {
        push @values, @$values;
    }

    # determine if condition is fulfilled
    my $ok;

    if (@values) {
        $ok = any { $when_field_value eq $_ } @values;
    }
    else {
        $ok = $when_field_value ? 1 : 0;
    }

    # invert when condition if asked for
    $ok = $when->{not} ? !$ok : $ok;

    return $ok;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    if ( defined( my $when = $self->when ) ) {
        $clone->when( dclone $when );
    }

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint - Constrain User Input

=head1 SYNOPSIS

    ---
    elements:
      - type: Text
        name: foo
        constraints:
          - type: Length
            min: 8
            when:
              field: bar
              values: [ 1, 3, 5 ]
      - type: Text
        name: bar
        constraints:
          - Integer
          - Required
    constraints:
      - SingleValue

=head1 DESCRIPTION

User input is processed in the following order:

=over

=item L<Filters|HTML::FormFu::Filter>

=item L<Constraints|HTML::FormFu::Constraint>

=item L<Inflators|HTML::FormFu::Inflator>

=item L<Validators|HTML::FormFu::Validator>

=item L<Transformers|HTML::FormFu::Transformer>

=back

See L<HTML::FormFu/"FORM LOGIC AND VALIDATION"> for further details.

L<HTML::FormFu/constraints> can be called on any L<form|HTML::FormFu>,
L<block element|HTML::FormFu::Element::Block> (includes fieldsets) or
L<field element|HTML::FormFu::Element::_Field>.

If called on a field element, no C<name> argument should be passed.

If called on a L<form|HTML::FormFu> or
L<block element|HTML::FormFu::Element::Block>, if no C<name> argument is
provided, a new constraint is created for and added to every field on that
form or block.

See L<HTML::FormFu/"FORM LOGIC AND VALIDATION"> for further details.

=head1 METHODS

=head2 type

Returns the C<type> argument originally used to create the constraint.

=head2 not

If true, inverts the results of the constraint - such that input that would
otherwise fail will pass, and vise-versa.

This value is ignored by some constraints - see the documentation for
individual constraints for details.

=head2 only_on_reps

Argument: \@repeatable_count

For constraints added to fields within a
L<Repeatable|HTML::FormFu::Element::Repeatable> element, if C<only_on_reps>
is set, the constraint will only be run for fields whose
L<repeatable_count|HTML::FormFu::Element::_Field/repeatable_count>
matches one of these set values.

Not available for the constraints listed in
L<HTML::FormFu::Element::Repeatable/"Unsupported Constraints">.

=head2 message

Arguments: $string

Set the message which will be displayed if the constraint fails.

=head2 message_xml

Arguments: $string

Variant of L</message> which ensures the value won't be XML-escaped.

=head2 message_loc

Arguments: $string

Variant of L</message> which uses L<localize|HTML::FormFu/localize> to
create the message.

=head2 localise_args

Provide arguments that should be passed to L<localize|HTML::FormFu/localize>
to replace C<[_1]>, C<[_2]>, etc. in the localized string.

=head2 force_errors

See L<HTML::FormFu/force_errors> for details.

=head2 parent

Returns the L<field|HTML::FormFu::Element::_Field> object that the constraint
is associated with.

=head2 form

Returns the L<HTML::FormFu> object that the constraint's field is attached
to.

=head2 name

Shorthand for C<< $constraint->parent->name >>

=head2 when

Defines a condition for the constraint. Only when the condition is fullfilled
the constraint will be applied.

This method expects a hashref.

The C<field> or C<callback> must be supplied, all other fields are optional.

If C<value> or C<values> is not supplied, the constraint will pass if the
named field's value is true.

The following keys are supported:

=over

=item field

nested-name of form field that shall be checked against

=item value

Expected value in the form field 'field'

=item values

Array of multiple values, one must match to fullfill the condition

=item not

Inverts the when condition - value(s) must not match

=item callback

A callback subroutine-reference or fully resolved subroutine name can be
supplied to perform complex checks. An hashref of all parameters is passed
to the callback sub. In this case all other keys are ignored, including not.
You need to return a true value for the constraint to be applied or a false
value to not apply it.

=back

=head1 CORE CONSTRAINTS

=over

=item L<HTML::FormFu::Constraint::AllOrNone>

=item L<HTML::FormFu::Constraint::ASCII>

=item L<HTML::FormFu::Constraint::AutoSet>

=item L<HTML::FormFu::Constraint::Bool>

=item L<HTML::FormFu::Constraint::Callback>

=item L<HTML::FormFu::Constraint::CallbackOnce>

=item L<HTML::FormFu::Constraint::DateTime>

=item L<HTML::FormFu::Constraint::DependOn>

=item L<HTML::FormFu::Constraint::Email>

=item L<HTML::FormFu::Constraint::Equal>

=item L<HTML::FormFu::Constraint::File>

=item L<HTML::FormFu::Constraint::File::MIME>

=item L<HTML::FormFu::Constraint::File::MaxSize>

=item L<HTML::FormFu::Constraint::File::MinSize>

=item L<HTML::FormFu::Constraint::File::Size>

=item L<HTML::FormFu::Constraint::Integer>

=item L<HTML::FormFu::Constraint::Length>

=item L<HTML::FormFu::Constraint::MaxLength>

=item L<HTML::FormFu::Constraint::MaxRange>

=item L<HTML::FormFu::Constraint::MinLength>

=item L<HTML::FormFu::Constraint::MinRange>

=item L<HTML::FormFu::Constraint::MinMaxFields>

=item L<HTML::FormFu::Constraint::Number>

=item L<HTML::FormFu::Constraint::Printable>

=item L<HTML::FormFu::Constraint::Range>

=item L<HTML::FormFu::Constraint::reCAPTCHA>

=item L<HTML::FormFu::Constraint::Regex>

=item L<HTML::FormFu::Constraint::Required>

=item L<HTML::FormFu::Constraint::Set>

=item L<HTML::FormFu::Constraint::SingleValue>

=item L<HTML::FormFu::Constraint::Word>

=back

=head1 CAVEATS

See L<HTML::FormFu::Element::Repeatable/"Unsupported Constraints">
for a list of constraints that won't work within
L<HTML::FormFu::Element::Repeatable>.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint>, by
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
