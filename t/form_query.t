use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

# NO QUERY
{
    is( "$form", <<EOF, 'stringified form' );
<form action="" method="post">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="text">
<input name="bar" type="text" />
</span>
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
<span class="text">
<input name="foo" type="text" value="yada" />
</span>
<span class="text">
<input name="bar" type="text" value="23" />
</span>
</form>
EOF
}
