use strict;
use warnings;

use Test::More tests => 20;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('name')->filter('LowerCase');
$form->element('Text')->name('age');

$form->filter( HTMLEscape => 'name', 'age' );
$form->filter('Whitespace');

{
    my $filters = $form->get_filters;

    is( @$filters, 5, '5 filters' );

    is( $filters->[0]->name, 'name' );
    is( $filters->[1]->name, 'name' );
    is( $filters->[2]->name, 'name' );
    is( $filters->[3]->name, 'age' );
    is( $filters->[4]->name, 'age' );

    is( $filters->[0]->type, 'LowerCase' );
    is( $filters->[1]->type, 'HTMLEscape' );
    is( $filters->[2]->type, 'Whitespace' );
    is( $filters->[3]->type, 'HTMLEscape' );
    is( $filters->[4]->type, 'Whitespace' );
}

{
    my $filters = $form->get_filters('name');

    is( @$filters, 3, '3 filters' );

    is( $filters->[0]->type, 'LowerCase' );
    is( $filters->[1]->type, 'HTMLEscape' );
    is( $filters->[2]->type, 'Whitespace' );
}

{
    my $filters = $form->get_filters( { name => 'age' } );

    is( @$filters, 2, '2 filters' );

    is( $filters->[0]->type, 'HTMLEscape' );
    is( $filters->[1]->type, 'Whitespace' );
}

{
    my $filters = $form->get_filters( { type => 'LowerCase' } );

    is( @$filters, 1, '1 filter' );

    is( $filters->[0]->name, 'name' );
}
