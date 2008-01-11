use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'rg' } );

my $field = $form->element('Radiogroup')->name('foo')->value(2)
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<fieldset class="radiogroup">
<span>
<span>
<input name="rg.foo" type="radio" value="1" />
<label>One</label>
</span>
<span>
<input name="rg.foo" type="radio" value="2" checked="checked" />
<label>Two</label>
</span>
</span>
</fieldset>
</fieldset>
</form>
EOF

$form->process( {
        "rg.foo" => 1,
    } );

is( $form->param('rg.foo'), 1 );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<fieldset class="radiogroup">
<span>
<span>
<input name="rg.foo" type="radio" value="1" checked="checked" />
<label>One</label>
</span>
<span>
<input name="rg.foo" type="radio" value="2" />
<label>Two</label>
</span>
</span>
</fieldset>
</fieldset>
</form>
EOF

