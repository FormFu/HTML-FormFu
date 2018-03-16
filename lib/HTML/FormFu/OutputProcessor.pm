use strict;
package HTML::FormFu::OutputProcessor;
# ABSTRACT: Post-process HTML output


use Moose;
use MooseX::Attribute::Chained;

with 'HTML::FormFu::Role::HasParent', 'HTML::FormFu::Role::Populate';

use HTML::FormFu::ObjectUtil qw( form parent );

has type => ( is => 'rw', traits => ['Chained'] );

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

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
