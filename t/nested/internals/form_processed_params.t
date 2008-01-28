use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

my $bar = $form->element('Text')->name('bar');

$form->process( {
        'foo.bar' => 'x',
        foo       => { bar => 'x', },
    } );

is_deeply( $form->_processed_params, { foo => { bar => 'x', }, }, );
