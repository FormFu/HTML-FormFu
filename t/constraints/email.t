use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

{

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Email');

# Valid
{
    $form->process( { foo => 'cfranks@cpan.org', } );

    ok( $form->valid('foo'), 'foo valid' );
}

# Invalid
{
    $form->process( { foo => 'cfranks@cpan', } );

    ok( $form->has_errors('foo'), 'foo has errors' );
}

# Email with IP valid by default
{

    $form->process( { foo => 'rjbs@[1.2.3.4]' } );

    ok( $form->valid('foo'), 'foo valid - ip ok by default' );

}

}

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

{

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Email')->options({'allow_ip' => 0 });

# Email with IP invalid when turned off
{

    $form->process( { foo => 'rjbs@[1.2.3.4]' } );

    ok( $form->has_errors('foo'), 'foo valid - ip invalid when turned off' );

}

# Email with space - invalid
{

    $form->process( { foo => 'Valid+except @space.org' } );

    ok( $form->has_errors('foo'), 'email with space is invalid' );

}

}
