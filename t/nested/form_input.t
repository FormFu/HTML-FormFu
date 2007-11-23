use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

my $bar = $form->element('Text')->name('bar');

$form->process({
    'foo.bar' => 'x',
    foo => {
        bar => 'x',
    },
});

is_deeply(
    $form->input,
    {
        foo => {
            bar => 'x',
        },
    }, 
);
