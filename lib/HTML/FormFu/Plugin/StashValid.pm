package HTML::FormFu::Plugin::StashValid;

use strict;
use base 'HTML::FormFu::Plugin';
use Class::C3;

sub post_process {
    my ($self) = @_;

    my $form = $self->form;
    my $name = $self->parent->nested_name;

    if ( $form->valid($name) ) {
        $form->stash->{$name} = $form->param($name);
    }

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Plugin::StashValid - place valid params on form stash

=head1 SYNOPSIS

    # called on a form or block
    ---
    plugins:
      - type: StashValid
        names: ['field-names']

    # called on a field
    ---
    elements:
      - name: foo
        plugins: 
          - StashValid

=head1 DESCRIPTION

Run during the L<HTML::FormFu::Plugin/post_process> hook (called during
L<HTML::FormFu/process>).
If the named field(s) have a valid value after processing, that value is 
placed on the form stash, using the field-name as the stash-key.

=head1 METHODS

Arrayref of field names, whose valid values should be stashed.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Plugin>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
