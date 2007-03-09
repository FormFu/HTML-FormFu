use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo[bar]');

{
    $form->process({ 'foo[bar]' => 'bam' });

    is( $form->param('foo[bar]'), 'bam', 'foo[bar] valid' );
}

