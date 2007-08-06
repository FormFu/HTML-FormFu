use strict;
use warnings;

use Test::More tests => 16;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('date')
    ->name('foo')
    ->strftime("%m/%d/%Y")
    ->auto_inflate(1)
    ->constraint('Required');

$form->element('date')
    ->name('bar');

like( $form->get_field('foo'), qr/\Q<option value="2007">/ );
like( $form->get_field('bar'), qr/\Q<option value="2007">/ );

$form->process({
    'foo.day', 30,
    'foo.month', 6,
    'foo.year', 2007,
    'bar.day', 1,
    'bar.month', 7,
    'bar.year', 2007,
    });

ok( $form->submitted_and_valid );

isa_ok( $form->params->{foo}, 'DateTime' );
ok( !ref $form->params->{bar} );

is( $form->params->{foo}, "06/30/2007" );
is( $form->params->{bar}, "01-07-2007" );

like( $form->get_field('foo'), qr/\Q<option value="30" selected="selected">/ );
like( $form->get_field('foo'), qr/\Q<option value="6" selected="selected">/ );
like( $form->get_field('foo'), qr/\Q<option value="2007" selected="selected">/ );

like( $form->get_field('bar'), qr/\Q<option value="1" selected="selected">/ );
like( $form->get_field('bar'), qr/\Q<option value="7" selected="selected">/ );
like( $form->get_field('bar'), qr/\Q<option value="2007" selected="selected">/ );

# incorrect date

$form->process({
    'foo.day', 29,
    'foo.month', 2,
    'foo.year', 2007,
});

ok( $form->submitted );
ok( $form->has_errors );
ok( !defined $form->params->{foo} );

