use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $e1 = $form->element('Text')->name('foo');
my $e2 = $form->element('Text')->name('bar');

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
