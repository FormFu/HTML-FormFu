use strict;
use warnings;
use Scalar::Util qw/ refaddr /;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('Fieldset')->id('fs');

my $field = $fs->element('Text')->name('foo')->id('foo');

$field->constraint('Required');

my $clone = $form->clone;

$clone->process( { foo => '' } );

is( refaddr( $clone->get_element->parent ), refaddr($clone), );

is( refaddr( $clone->get_field->parent ), refaddr( $clone->get_element ), );

is( refaddr( $clone->get_constraint->parent ), refaddr( $clone->get_field ), );

is( refaddr( $clone->get_error->parent ), refaddr( $clone->get_field ), );

=pod

Ensure that modifying attributes on the clone doesn't modify the original form.

=cut

$clone->get_element->attrs( { id => 'fs2' } );

$clone->get_field->attrs( { id => 'foo2' } );

is_deeply( $form->get_element->attributes, { id => 'fs' } );

is_deeply( $form->get_field->attributes, { id => 'foo' } );

is_deeply( $clone->get_element->attributes, { id => 'fs2' } );

is_deeply( $clone->get_field->attributes, { id => 'foo2' } );
