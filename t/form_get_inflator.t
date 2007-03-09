use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $e1 = $form->element('text')->name('foo');
my $e2 = $form->element('text')->name('bar');

$form->inflator( DateTime => 'foo', 'bar' );

{
    my @i = $form->get_inflator;

    is( @i, 1 );
}

{
    my @i = $form->get_inflator('foo');

    is( @i, 1 );
}

{
    my @i = $e1->get_inflator;

    is( @i, 1 );
}

{
    my @i = $e1->get_inflator( { name => 'foo' } );

    is( @i, 1 );
}

{
    my @i = $e2->get_inflator;

    is( @i, 1 );
}

{
    my @i = $e2->get_inflator( { name => 'bar' } );

    is( @i, 1 );
}

{
    my @i = $e2->get_inflator( { name => 'foo' } );

    is( @i, 0 );
}
