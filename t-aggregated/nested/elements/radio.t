use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'radio' } );

$form->element('Radio')->name('foo')->value('foox');

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div class="radio">
<input name="radio.foo" type="radio" value="foox" />
</div>
</fieldset>
</form>
EOF

{
    $form->process( { 'radio.foo' => 'foox', } );

    ok( $form->valid('radio.foo') );

    is( $form->param('radio.foo'), 'foox' );

    like( $form->get_field('foo'), qr/checked/ );
}
