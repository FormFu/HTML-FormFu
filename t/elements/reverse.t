use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

# add element to test reverse_single reversing labels
my $field1 = $form->element('Text')->name('foo1')->label('My Foo 1')
    ->reverse_single(1);

# add element to test reverse_multi reversing labels in multi
my $multi1 = $form->element('Multi')->label('My Multi 1');
$multi1->element('Text')->name('bar1')->label('My Bar 1')->reverse_multi(1);

# add element to test reverse_multi not reversing labels outside multi
my $field2
    = $form->element('Text')->name('foo2')->label('My Foo 2')->reverse_multi(1);

# add element to test reverse_single not reversing labels in multi
my $multi2 = $form->element('Multi')->label('My Multi 2');
$multi2->element('Text')->name('bar2')->label('My Bar 2')->reverse_single(1);

my $field1_xhtml = qq{<div class="text label">
<input name="foo1" type="text" />
<label>My Foo 1</label>
</div>};

is( "$field1", $field1_xhtml, 'reverse_single normal' );

my $multi1_xhtml = qq{<div class="multi label">
<label>My Multi 1</label>
<span class="elements">
<input name="bar1" type="text" />
<label>My Bar 1</label>
</span>
</div>};

is( "$multi1", $multi1_xhtml, 'reverse_multi normal' );

my $field2_xhtml = qq{<div class="text label">
<label>My Foo 2</label>
<input name="foo2" type="text" />
</div>};

is( "$field2", $field2_xhtml, 'reverse_multi outside multi' );

my $multi2_xhtml = qq{<div class="multi label">
<label>My Multi 2</label>
<span class="elements">
<label>My Bar 2</label>
<input name="bar2" type="text" />
</span>
</div>};

is( "$multi1", $multi1_xhtml, 'reverse_single inside multi' );
