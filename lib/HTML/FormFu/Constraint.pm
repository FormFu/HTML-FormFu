package HTML::FormFu::Constraint;

use strict;
use base 'HTML::FormFu::Processor';
use Class::C3;

use HTML::FormFu::Exception::Constraint;
use Scalar::Util qw/ blessed /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ not force_errors /);

sub process {
    my ( $self, $params ) = @_;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @errors;

    if ( ref $value ) {
        eval { my @x = @$value };
        croak $@ if $@;

        push @errors, eval { $self->constrain_values( $value, $params ); };
        if ($@) {
            push @errors,
                $self->mk_errors( {
                    pass    => 0,
                    message => $@,
                } );
        }
    }
    else {
        my $ok = eval { $self->constrain_value( $value, $params ); };
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
        my $ok = eval { $self->constrain_value( $value, $params ); };

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
    my $name = $self->name;
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

1;

__END__

=head1 NAME

HTML::FormFu::Constraint - Constraint Base Class

=head1 SYNOPSIS

    ---
    elements: 
      - type: text
        name: foo
        constraints:
          - type: Length
            min: 8
      - type: text
        name: bar
        constraints: 
          - Integer
          - Required
    constraints: 
      - SingleValue

=head1 DESCRIPTION

C<constraints()> and C<constraint> can be called on any 
L<form|HTML::FormFu>, L<block element|HTML::FormFu::Element::Block> 
(includes fieldsets) or L<field element|HTML::FormFu::Element::_Field>.

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

=head2 parent

Returns the L<HTML::FormFu::Element::_Field> object that the constraint is 
associated with.

=head2 form

Returns the L<HTML::FormFu> object that the constraint's field is attached 
to.

=head2 name

Shorthand for C<< $constraint->parent->name >>

=head1 CORE CONSTRAINTS

=over

=item L<HTML::FormFu::Constraint::AllOrNone>

=item L<HTML::FormFu::Constraint::ASCII>

=item L<HTML::FormFu::Constraint::AutoSet>

=item L<HTML::FormFu::Constraint::Bool>

=item L<HTML::FormFu::Constraint::Callback>

=item L<HTML::FormFu::Constraint::CallbackOnce>

=item L<HTML::FormFu::Constraint::DependOn>

=item L<HTML::FormFu::Constraint::Email>

=item L<HTML::FormFu::Constraint::Equal>

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
