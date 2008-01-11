use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

# attach to field
$form->element('Text')->name('bar')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } )->strptime('%d/%m/%Y');

$form->element('Text')->name('baz');

# attach via form
$form->inflator({
        type => 'DateTime',
        name => 'foo.baz',
        parser => { strptime => '%d/%m/%Y' },
        strptime => { pattern => '%m-%d-%Y' },
    });

$form->process( {
        'foo.bar' => '31/12/2006',
        'foo.baz' => '1/07/2007',
    } );

{
    my $value = $form->param('foo.bar');
    
    isa_ok( $value, 'DateTime' );
    is( $value, "31/12/2006" );
}

{
    my $value = $form->param('foo.baz');
    
    isa_ok( $value, 'DateTime' );
    is( $value, "07-01-2007" );
}

