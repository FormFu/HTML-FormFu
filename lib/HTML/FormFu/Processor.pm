package HTML::FormFu::Processor;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ parent not localize_args /);

__PACKAGE__->mk_output_accessors(qw/ message /);

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Processor - base class for constraints

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
