use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->tt_args( { INCLUDE_PATH => ['root'], } );

$form->add_tt_args( { TEMPLATE_ALLOY => 1, } );

is_deeply(
    $form->tt_args,
    {   INCLUDE_PATH   => ['root'],
        TEMPLATE_ALLOY => 1,
    } );

