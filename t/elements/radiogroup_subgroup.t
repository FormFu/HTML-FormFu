use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Radiogroup')->name('foo')->default(2)->options( [
        { group => [ [ 1 => 'one' ], [ 2 => 'two' ] ] },
        {   group => [ [ foo2_1 => 'One' ], [ foo2_2 => 'Two' ] ],
            label => 'foo2',
        },
        [ x => 'non-opt' ],
        {   group => [
                { label => 'wun', value => 'foo3_1' },
                {   label      => 'too',
                    value      => 'foo3_2',
                    attributes => { class => 'foo3b' } }
            ],
            label      => 'foo3',
            attributes => { class => 'opt4' },
        },
    ] );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset class="radiogroup">
<span>
<span class="subgroup">
<span>
<input name="foo" type="radio" value="1" />
<label>one</label>
</span>
<span>
<input name="foo" type="radio" value="2" checked="checked" />
<label>two</label>
</span>
</span>
<span class="subgroup">
<span>
<input name="foo" type="radio" value="foo2_1" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="foo2_2" />
<label>Two</label>
</span>
</span>
<span>
<input name="foo" type="radio" value="x" />
<label>non-opt</label>
</span>
<span class="opt4 subgroup">
<span>
<input name="foo" type="radio" value="foo3_1" />
<label>wun</label>
</span>
<span>
<input name="foo" type="radio" value="foo3_2" class="foo3b" />
<label>too</label>
</span>
</span>
</span>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );

# With mocked basic query
{
    $form->process( { foo => 'foo3_1', } );

    my $xml = $form->get_field('foo');

    like( "$xml", qr/value="foo3_1" checked="checked"/ );

    my $count = $xml =~ s/checked="checked"/checked="checked"/g;

    is( $count, 1 );
}
