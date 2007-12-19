use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Radiogroup')->name('foo')
    ->options( [
    {
        label => 'One',
        attrs => { class => 'foo' },
        attrs_xml => { onsubmit => '<dont-quote>' },
    }
    ] );


is ( "$form", <<EOF );
<form action="" method="post">
<fieldset class="radiogroup">
<span>
<span>
<input name="foo" type="radio" value="" class="foo" onsubmit="<dont-quote>" />
<label>One</label>
</span>
</span>
</fieldset>
</form>
EOF
