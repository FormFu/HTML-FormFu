use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->inflator('DateTime')
    ->parser( { strptime => '%Y-%m-%d %H:%M' } )
    ->strptime('%H:%M [%Y-%m-%d] %z')
    ->time_zone('Europe/Rome');

$form->process( {
        foo => '2008-07-23 08:52',
    } );

is( ref $form->params->{foo}->time_zone, 'DateTime::TimeZone::Europe::Rome' );
is( $form->params->{foo}, '08:52 [2008-07-23] +0200' );
