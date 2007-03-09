use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

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
