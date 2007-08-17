use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element({ type => 'submit', name => 'foo', default => 'Foo' });
$form->element({ type => 'submit', name => 'bar', default => 'Bar' });

my $foo = qq{<input name="foo" type="submit" value="Foo" />};
my $bar = qq{<input name="bar" type="submit" value="Bar" />};

is( $form->get_field('foo')->render->field_tag, $foo );
is( $form->get_field('bar')->render->field_tag, $bar );

# click 1st submit button

$form->process({
    foo => 'Foo',
});

# output unchanged

is( $form->get_field('foo')->render->field_tag, $foo );
is( $form->get_field('bar')->render->field_tag, $bar );
