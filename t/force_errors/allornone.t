use strict;
use warnings;

use Test::More tests => 24;

use HTML::FormFu;

my $form = HTML::FormFu->new->indicator( sub {1} );

$form->element('text')->name('foo')
    ->constraint('AllOrNone')->others(qw/ bar baz bif /)->force_errors(1);

$form->element('text')->name('bar');
$form->element('text')->name('baz');
$form->element('text')->name('bif');

# Valid
{
    $form->process({
            foo => 1,
            bar => 'a',
            baz => [2],
            bif => [ 3, 4 ],
        });

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    ok( $form->has_errors('bif') );
    
    ok( $form->get_errors('foo')->[0]{forced} );
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
    ok( $form->get_errors('bif')->[0]{forced} );
}

# Valid
{
    $form->process({});

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    ok( $form->has_errors('bif') );
    
    ok( $form->get_errors('foo')->[0]{forced} );
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
    ok( $form->get_errors('bif')->[0]{forced} );
}

# Invalid
{
    $form->process({
            foo => 1,
            bar => '',
            baz => [2],
            bif => [ 3, 4 ],
        } );

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    ok( $form->has_errors('bif') );
    
    ok( $form->get_errors('foo')->[0]{forced} );
    ok( !$form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
    ok( $form->get_errors('bif')->[0]{forced} );
}
