package HTML::FormFu::Constraint;

use strict;
use base 'HTML::FormFu::Processor';
use Class::C3;

use HTML::FormFu::Exception::Constraint;
use List::MoreUtils qw( any );
use Scalar::Util qw( blessed );
use Carp qw( croak );

__PACKAGE__->mk_item_accessors( qw( not force_errors when ) );

sub process {
    my ( $self, $params ) = @_;

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    my @errors;

    # check when condition
    return if !$self->_process_when($params);

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
        push @errors,
            $self->mk_errors( {
                pass => ( $@ || !$ok ) ? 0 : 1,
                message => $@,
            } );
    }

    return @errors;
}

sub constrain_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval { $self->constrain_value( $value, $params ) };

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
    my $when_field_value = $params->{$when_field};
    return 0 if !defined $when_field_value;

    # a compare value must be defined
    my @values;
    my $compare_value = $when->{value};
    
    if ( defined $compare_value ) {
        push @values, $compare_value;
    }
    
    my $compare_values = $when->{values};
    
    if ( ref $compare_values eq 'ARRAY' ) {
        push @values, @$compare_values;
    }
    
    croak "Parameter 'value' or 'values' are not defined" if !@values;

    # determine if condition is fullfilled
    my $fullfilled = any { $when_field_value eq $_ } @values;

    # invert when condition if asked for
    $fullfilled = $when->{not} ? !$fullfilled : $fullfilled;

    return $fullfilled;
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

=item L<Filters|HTML::FormFu::Filter|HTML::FormFu::Filter>

=item L<Constraints|HTML::FormFu::Constraint|HTML::FormFu::Constraint>

=item L<Inflators|HTML::FormFu::Inflator|HTML::FormFu::Inflator>

=item L<Validators|HTML::FormFu::Validator|HTML::FormFu::Validator>

=item L<Transformers|HTML::FormFu::Transformer|HTML::FormFu::Transformer>

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

This method expects a hashref with the following keys:
  field: name of form field that shall be compared
  value: expected value in the form field 'field'
  values: Array of multiple values, one must match to fullfill the condition
  not: inverse the when condition - value(s) must not match
  callback: a callback can be supplied to perform complex checks. An hashref
    of all parameters is passed to the callback sub. In this case all other
    keys are ignored, including not. You need to return a true value for
    the constraint to be applied or a false value to not apply it.

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

=item L<HTML::FormFu::Constraint::File::Size>

=item L<HTML::FormFu::Constraint::Integer>

=item L<HTML::FormFu::Constraint::Length>

=item L<HTML::FormFu::Constraint::MaxLength>

=item L<HTML::FormFu::Constraint::MinLength>

=item L<HTML::FormFu::Constraint::MinMaxFields>

=item L<HTML::FormFu::Constraint::Number>

=item L<HTML::FormFu::Constraint::Printable>

=item L<HTML::FormFu::Constraint::Range>

=item L<HTML::FormFu::Constraint::Regex>

=item L<HTML::FormFu::Constraint::Required>

=item L<HTML::FormFu::Constraint::Set>

=item L<HTML::FormFu::Constraint::SingleValue>

=item L<HTML::FormFu::Constraint::Word>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint>, by 
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
