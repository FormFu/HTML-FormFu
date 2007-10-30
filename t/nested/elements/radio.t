use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'radio' } );

$form->element('Radio')->name('foo')->value('foox');

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<span class="radio">
<input name="radio.foo" type="radio" value="foox" />
</span>
</fieldset>
</form>
EOF

{
    $form->process( {
            'radio.foo' => 'foox',
        } );

    ok( $form->valid('radio.foo') );

    is( $form->param('radio.foo'), 'foox' );

    like( $form->get_field('foo'), qr/checked/ );
}
