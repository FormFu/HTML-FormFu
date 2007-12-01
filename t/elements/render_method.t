use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

# ensure our form is using 'string'
delete $ENV{HTML_FORMFU_RENDER_METHOD};

# tt only needs to find our custom template
my $form = HTML::FormFu->new({
    tt_args => { INCLUDE_PATH => 't/templates' }
    });

$form->element('Text')->name('foo')->render_method('tt');
$form->element('Text')->name('bar');

is( "$form", <<HTML );
<form action="" method="post">
<TEXT name="foo" />
<span class="text">
<input name="bar" type="text" />
</span>
</form>
HTML

