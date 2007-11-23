use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');

# Valid
{
    $form->process( { foo => [ 'one', 'two' ] } );

    ok( $form->valid('foo'), 'foo valid' );

    my $params = $form->params;

    is_deeply( $params, { foo => [ 'one', 'two' ] } );
}
