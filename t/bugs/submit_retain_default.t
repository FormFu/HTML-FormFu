use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element( { type => 'Submit', name => 'foo', default => 'Foo' } );
$form->element( { type => 'Submit', name => 'bar', default => 'Bar' } );

my $foo = qq{<input name="foo" type="submit" value="Foo" />};
my $bar = qq{<input name="bar" type="submit" value="Bar" />};

like( $form->get_field('foo'), qr/\Q$foo/ );
like( $form->get_field('bar'), qr/\Q$bar/ );

# click 1st submit button

$form->process( { foo => 'Foo', } );

# output unchanged

like( $form->get_field('foo'), qr/\Q$foo/ );
like( $form->get_field('bar'), qr/\Q$bar/ );
