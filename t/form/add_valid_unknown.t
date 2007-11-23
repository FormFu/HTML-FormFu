use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');

$form->process( { foo => 1, } );

is_deeply( $form->params, { foo => 1, } );

$form->add_valid( bar => 'b' );

is_deeply(
    $form->params,
    {   foo => 1,
        bar => 'b',
    } );

