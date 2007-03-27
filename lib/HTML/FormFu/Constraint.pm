package HTML::FormFu::Constraint;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::Exception::Constraint;
use HTML::FormFu::ObjectUtil qw( populate form name );
use Scalar::Util qw/ blessed /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ parent constraint_type not localize_args /);

__PACKAGE__->mk_output_accessors(qw/ message /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw/ constraint_type /) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my ( $self, $params ) = @_;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @errors;

    if ( ref $value ) {
        eval { my @x = @$value };
        croak $@ if $@;

        push @errors, eval {
            $self->constrain_values( $value, $params );
        };
        if ($@) {
            push @errors, $self->return_error($@);
        }
    }
    else {
        my $ok = eval {
            $self->constrain_value( $value, $params ) ? 1 : 0;
        };
        if ( $@ or !$ok ) {
            push @errors, $self->return_error($@);
        }
    }

    return @errors;
}

sub constrain_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval {
            $self->constrain_value( $value, $params ) ? 1 : 0;
        };
        if ( $@ or !$ok ) {
            push @errors, $self->return_error($@)
        }
    }

    return @errors;
}

sub constrain_value {
    croak "constrain_value() should be overridden";
}

sub return_error {
    my ( $self, $err ) = @_;
    
    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Constraint') ) {
        $err = HTML::FormFu::Exception::Constraint->new;
    }
    
    return $err;
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::Widget::Constraint - Constraint Base Class

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
L<form|HTML::FormFu>, L<block element|HTML::FormFu::Element::block> 
(includes fieldsets) or L<field element|HTML::FormFu::Element::field>.

If called on a field element, no C<name> argument should be passed.

If called on a L<form|HTML::FormFu> or 
L<block element|HTML::FormFu::Element::block>, if no C<name> argument is 
provided, a new constraint is created for and added to every field on that 
form or block.

See L<HTML::FormFu/"FORM LOGIC AND VALIDATION"> for further details.

=head1 METHODS

=head2 constraint_type

Returns the C<type> argument originally used to create the constraint.

=head2 localise_args

Provide arguments that should be passed to L<localize|HTML::FormFu/localize> 
to replace C<[_1]>, C<[_2]>, etc. in the localized string.

=head2 parent

Returns the L<HTML::FormFu::Element::field> object that the constraint is 
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

=item L<HTML::FormFu::Constraint::MinMaxNeeded>

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
