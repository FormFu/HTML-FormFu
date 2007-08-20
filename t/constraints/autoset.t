use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# Autoset with multiple values

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->constraint('AutoSet');

# Valid
{
    $form->process( { foo => 'two', } );

    ok( $form->valid('foo') );
}

# Invalid
{
    $form->process( { foo => 'yes', } );

    ok( $form->has_errors('foo') );
}

# Autoset with a single value

$form->element('Select')->name('bar')->values( [qw/ one /] )
    ->constraint('AutoSet');

# Valid
{
    $form->process( { bar => 'one', } );

    ok( $form->valid('bar') );
}

# Invalid
{
    $form->process( { bar => 'yes', } );

    ok( $form->has_errors('bar') );
}

