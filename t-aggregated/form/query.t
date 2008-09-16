use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

# NO QUERY
{
    is( "$form", <<EOF, 'stringified form' );
<form action="" method="post">
<div class="text">
<input name="foo" type="text" />
</div>
<div class="text">
<input name="bar" type="text" />
</div>
</form>
EOF
}

# WITH QUERY
{
    $form->process( {
            foo => 'yada',
            bar => '23',
        } );

    is( $form->param('foo'), 'yada', 'param(foo)' );
    is( $form->param('bar'), 23,     'param(bar)' );

    is( "$form", <<EOF, 'stringified form' );
<form action="" method="post">
<div class="text">
<input name="foo" type="text" value="yada" />
</div>
<div class="text">
<input name="bar" type="text" value="23" />
</div>
</form>
EOF
}
