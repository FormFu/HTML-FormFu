use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $e1 = $form->element('text')->name('foo');
my $e2 = $form->element('text')->name('bar');

$form->deflator( Strftime => 'foo', 'bar' );

{
    my $d = $form->get_deflators;

    is( @$d, 2 );
}

{
    my $d = $form->get_deflators('foo');

    is( @$d, 1 );
}

{
    my $d = $e1->get_deflators;

    is( @$d, 1 );
}

{
    my $d = $e1->get_deflators( { name => 'foo' } );

    is( @$d, 1 );
}

{
    my $d = $e2->get_deflators;

    is( @$d, 1 );
}

{
    my $d = $e2->get_deflators( { name => 'bar' } );

    is( @$d, 1 );
}

{
    my $i = $e2->get_deflators( { name => 'foo' } );

    is( @$i, 0 );
}
