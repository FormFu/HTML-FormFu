package HTML::FormFu::Constraint::DependOn;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/ others /);

sub process {
    my ( $self, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my $first = $self->name;
    my @names = ref $others ? @{$others} : ($others);
    my @errors;

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

        if ( !$ok ) {
            my $field = $self->form->get_field({ name => $name })
                or die "DependOn->others() field not found: '$name'";
            
            push @errors, HTML::FormFu::Exception::Constraint->new({
                parent => $field,
                });
        }
    }

    return @errors;
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->others( dclone $self->others )
        if ref $self->others;
    
    return $clone;
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

If a value is submitted for the field this constraint is associated with, 
then a value must also be submitted for all fields named in L</others>.

If the constraint fails, the first field will not display an error, but all 
other named fields will.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 others

Arguments: \@field_names

=head2 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
