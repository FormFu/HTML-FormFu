use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

my $field = $form->element('ComboBox')
    ->name('bar')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] )
    ;

$form->process;

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div class="combobox">
<span class="elements">
<select name="foo.bar_select">
<option value=""></option>
<option value="1">One</option>
<option value="2">Two</option>
</select>
<input name="foo.bar_text" type="text" />
</span>
</div>
</fieldset>
</form>
EOF

$form->process({
    "foo.bar_select" => '2',
    "foo.bar_text"   => '',
});

is( $form->param("foo.bar"), 2 );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div class="combobox">
<span class="elements">
<select name="foo.bar_select">
<option value=""></option>
<option value="1">One</option>
<option value="2" selected="selected">Two</option>
</select>
<input name="foo.bar_text" type="text" value="" />
</span>
</div>
</fieldset>
</form>
EOF

$form->process({
    "foo.bar_select" => '',
    "foo.bar_text"   => '3',
});

is( $form->param("foo.bar"), 3 );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div class="combobox">
<span class="elements">
<select name="foo.bar_select">
<option value="" selected="selected"></option>
<option value="1">One</option>
<option value="2">Two</option>
</select>
<input name="foo.bar_text" type="text" value="3" />
</span>
</div>
</fieldset>
</form>
EOF
