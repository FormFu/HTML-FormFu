use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Radiogroup')->name('foo')->options( [
    {
        label => '>One',
        value => '>1'
    },
    {
        label_xml => '&Two',
        value_xml => '&2',
    },
    {
        group => [
            {
                label => '>Three',
                value => '>3',
            },
            {
                label_xml => '&Four',
                value_xml => '&4',
            }
        ],
    },
] );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset class="radiogroup">
<span>
<span>
<input name="foo" type="radio" value="&gt;1" />
<label>&gt;One</label>
</span>
<span>
<input name="foo" type="radio" value="&2" />
<label>&Two</label>
</span>
<span class="subgroup">
<span>
<input name="foo" type="radio" value="&gt;3" />
<label>&gt;Three</label>
</span>
<span>
<input name="foo" type="radio" value="&4" />
<label>&Four</label>
</span>
</span>
</span>
</fieldset>
</form>
EOF
