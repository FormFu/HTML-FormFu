package HTML::FormFu::Validator;

use strict;
use base 'HTML::FormFu::Processor';
use Class::C3;

use HTML::FormFu::Exception::Validator;
use Scalar::Util qw( reftype blessed );
use Carp qw( croak );

sub process {
    my ( $self, $params ) = @_;

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    my @errors;

    if ( ( reftype( $value ) || '' ) eq 'ARRAY' ) {
        push @errors, eval { $self->validate_values( $value, $params ) };

        if ($@) {
            push @errors, $self->return_error($@);
        }
    }
    else {
        my $ok = eval { $self->validate_value( $value, $params ) };

        if ( $@ or !$ok ) {
            push @errors, $self->return_error($@);
        }
    }

    return @errors;
}

sub validate_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval { $self->validate_value( $value, $params ) };

        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Validator') ) {
            push @errors, $@;
        }
        elsif ( $@ or !$ok ) {
            push @errors, HTML::FormFu::Exception::Validator->new;
        }
    }

    return @errors;
}

sub validate_value {
    croak "validate() should be overridden";
}

sub return_error {
    my ( $self, $err ) = @_;

    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Validator') ) {
        $err = HTML::FormFu::Exception::Validator->new;
    }

    return $err;
}

1;

__END__

=head1 NAME

HTML::FormFu::Validator - Validator Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 CORE VALIDATORS

=head1 BEST PRACTICES

Try to avoid using callbacks if possible. Below is a more maintainable
and reusable approach, which also keeps the code out of the controller.

A normal application's directory would contain:

    lib/HTML/FormFu/Constraint/MyApp/
    lib/HTML/FormFu/Validator/MyApp/
    lib/HTML/FormFu/Plugin/MyApp/
    etc.

Then, the form config file would just need:

    validator: 'MyApp::SomeValidator'

And the class would be something like this:

    package HTML::FormFu::Validator::MyApp::SomeValidator;
    use strict;
    use warnings;
    use base 'HTML::FormFu::Validator';

    sub validate_value {
        my ( $self, $value, $params ) = @_;

        my $c = $self->form->stash->{context};

        return 1 if $c->model('DBIC')->is_valid($value);

        # assuming you want to return a custom error message
        # which perhaps includes something retrieved from the model
        # otherwise, just return 0
        die HTML::FormFu::Exception::Validator->new({
            message => 'custom error message',
        });
    }

    1;

=over

=item L<HTML::FormFu::Validator::Callback>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
