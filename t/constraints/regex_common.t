use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

map { $_->common( 'URI', 'HTTP', { -scheme => 'https?' } ) }
    $form->constraint('Regex');

{
    $form->process( {
            foo => 'http://perl.org',
            bar => 'ftp://perl.org',
        } );

    ok( $form->valid('foo') );
    ok( $form->has_errors('bar') );
}

{
    $form->process( {
            foo => 'https://perl.org',
            bar => 'www.perl.org',
        } );

    ok( $form->valid('foo') );
    ok( $form->has_errors('bar') );
}
