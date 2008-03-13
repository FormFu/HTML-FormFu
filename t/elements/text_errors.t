use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $foo = $form->element('Text')->name('foo')->label('My Foo');
my $bar = $form->element('Text')->name('bar');

$form->constraint( Number   => 'foo' );
$form->constraint( Word     => 'bar' );
$form->constraint( Required => 'foo', 'bar' );

my $foo_xhtml = qq{<div class="text label">
<label>My Foo</label>
<input name="foo" type="text" />
</div>};

is( "$foo", $foo_xhtml );

my $bar_xhtml = qq{<div class="text">
<input name="bar" type="text" />
</div>};

is( "$bar", $bar_xhtml );
