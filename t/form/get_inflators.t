use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $e1 = $form->element('Text')->name('foo');
my $e2 = $form->element('Text')->name('bar');

$form->inflator( DateTime => 'foo', 'bar' );

{
    my $i = $form->get_inflators;

    is( @$i, 2 );
}

{
    my $i = $form->get_inflators('foo');

    is( @$i, 1 );
}

{
    my $i = $e1->get_inflators;

    is( @$i, 1 );
}

{
    my $i = $e1->get_inflators( { name => 'foo' } );

    is( @$i, 1 );
}

{
    my $i = $e2->get_inflators;

    is( @$i, 1 );
}

{
    my $i = $e2->get_inflators( { name => 'bar' } );

    is( @$i, 1 );
}

{
    my $i = $e2->get_inflators( { name => 'foo' } );

    is( @$i, 0 );
}
