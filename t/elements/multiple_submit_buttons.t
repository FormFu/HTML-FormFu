use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Submit')->name('foo')->default('a');
$form->element('Submit')->name('foo')->default('b');
$form->element('Submit')->name('foo')->default('c');

$form->process( {
        foo => 'b',
    } );

ok( $form->submitted_and_valid );

is( "$form", <<HTML );
<form action="" method="post">
<div class="submit">
<input name="foo" type="submit" value="a" />
</div>
<div class="submit">
<input name="foo" type="submit" value="b" />
</div>
<div class="submit">
<input name="foo" type="submit" value="c" />
</div>
</form>
HTML
