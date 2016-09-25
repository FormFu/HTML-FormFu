use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Submit')->name('submit')->non_param(1);

# Required constraint not affected by non_param()
$form->constraints('Required');

# indicator not affected by non_param()
$form->indicator('submit');

$form->process( {
        foo    => 1,
        submit => 'Submit',
    } );

is( $form->param('foo'), 1 );
ok( !$form->param('submit') );

is_deeply( [ $form->valid ], ['foo'] );

ok( $form->valid('foo') );
ok( !$form->valid('submit') );

is_deeply( $form->params, { foo => 1, } );

