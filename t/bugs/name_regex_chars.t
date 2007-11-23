use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo/bar');

{
    $form->process( { 'foo/bar' => 'bam' } );

    is( $form->param('foo/bar'), 'bam', 'foo/bar valid' );
}

