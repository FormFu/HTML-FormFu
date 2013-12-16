use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->id('foo')->action('/bar')->enctype('unknown')->method('get');

is( $form->id,      'foo',     'form id' );
is( $form->action,  '/bar',    'form action' );
is( $form->enctype, 'unknown', 'form enctype' );
is( $form->method,  'get',     'form method' );

is_deeply(
    $form->attributes,
    {   id      => 'foo',
        action  => '/bar',
        enctype => 'unknown',
        method  => 'get',
    },
    'form attributes',
);

my $form_xhtml = <<EOF;
<form action="/bar" enctype="unknown" id="foo" method="get">
</form>
EOF

is( "$form", $form_xhtml );

