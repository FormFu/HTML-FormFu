use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('text')->name('foo')->label('My Foo');
my $bar = $form->element('text')->name('bar');

$form->constraint( Number   => 'foo' );
$form->constraint( Word     => 'bar' );
$form->constraint( Required => 'foo', 'bar' );

my $foo_xhtml = qq{<span class="text label">
<label>My Foo</label>
<input name="foo" type="text" />
</span>};

is( "$foo", $foo_xhtml );

my $bar_xhtml = qq{<span class="text">
<input name="bar" type="text" />
</span>};

is( "$bar", $bar_xhtml );
