use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('name');
$form->element('Text')->name('age');

$form->filter( HTMLEscape => 'name', 'age' );
$form->filter( LowerCase => 'name' );
$form->filter('Whitespace');

{
    my @filters = $form->get_filter;

    is( @filters, 1, '1 filter' );
}

{
    my @filters = $form->get_filter('name');

    is( @filters, 1, '1 filter' );
}

{
    my @filters = $form->get_filter( { name => 'age' } );

    is( @filters, 1, '1 filter' );
}

{
    my @filters = $form->get_filter( { type => 'LowerCase' } );

    is( @filters, 1, '1 filter' );
}
