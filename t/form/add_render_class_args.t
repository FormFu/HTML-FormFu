use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ render_class_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->render_class_args( { INCLUDE_PATH => ['root'], } );

$form->add_render_class_args( { TEMPLATE_ALLOY => 1, } );

is_deeply(
    $form->render_class_args,
    {   INCLUDE_PATH   => ['root'],
        TEMPLATE_ALLOY => 1,
    } );

