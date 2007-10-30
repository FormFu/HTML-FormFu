use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

my $field = $form->element('Select')->name('bar')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );


is ( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<span class="select">
<select name="foo.bar">
<option value="1">One</option>
<option value="2">Two</option>
</select>
</span>
</fieldset>
</form>
EOF

$form->process( { "foo.bar" => '2', } );

is( $form->param("foo.bar"), 2 );

is ( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<span class="select">
<select name="foo.bar">
<option value="1">One</option>
<option value="2" selected="selected">Two</option>
</select>
</span>
</fieldset>
</form>
EOF

