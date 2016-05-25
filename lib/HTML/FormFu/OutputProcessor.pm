package HTML::FormFu::OutputProcessor;

use strict;
# VERSION

use Moose;
use MooseX::Attribute::FormFuChained;

with 'HTML::FormFu::Role::HasParent', 'HTML::FormFu::Role::Populate';

use HTML::FormFu::ObjectUtil qw( form parent );

has type => ( is => 'rw', traits => ['FormFuChained'] );

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::OutputProcessor - Post-process HTML output

=head1 DESCRIPTION

Post-process a form or element's HTML.

=head1 CORE OUTPUT PROCESSORS

=over

=item L<HTML::FormFu::OutputProcessor::Indent>

=item L<HTML::FormFu::OutputProcessor::StripWhitespace>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
