use strict;
use warnings;

use Test::RequiresInternet 'cpan.org' => 80;
use Test::More tests => 3;

use HTML::FormFu;

{

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Email')->options('mxcheck');

# Valid - Scalar
{

    $form->process( { foo => 'cfranks@cpan.org' } );

    ok( $form->valid('foo'), 'foo valid - mxcheck scalar' );

}

}

{

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Email')->options(['mxcheck']);

# Valid - Array
{

    $form->process( { foo => 'djzort@cpan.org' } );

    ok( $form->valid('foo'), 'foo valid - mxcheck array' );

}

}

{

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Email')->options({'mxcheck' => 1 });

# Valid - Hash
{

    $form->process( { foo => 'djzort@cpan.org', options => { 'mxcheck' => 1 } } );

    ok( $form->valid('foo'), 'foo valid - mxcheck hash' );

}

}
