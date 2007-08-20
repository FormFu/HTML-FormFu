use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('Fieldset')->id('fs');

$fs->element('Text')->name('foo')->id('foo');

my $clone = $form->clone;

=pod

Ensure that modifying attributes on the clone doesn't modify the original form.

=cut

$clone->get_element->attrs( { id => 'fs2' } );

$clone->get_field->attrs( { id => 'foo2' } );

is_deeply( $form->get_element->attributes, { id => 'fs' } );

is_deeply( $form->get_field->attributes, { id => 'foo' } );

is_deeply( $clone->get_element->attributes, { id => 'fs2' } );

is_deeply( $clone->get_field->attributes, { id => 'foo2' } );
