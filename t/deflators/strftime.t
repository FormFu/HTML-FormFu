use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use DateTime;

my $value = DateTime->new(
    day   => 31,
    month => 12,
    year  => 2006,
);

my $form = HTML::FormFu->new;

my $e = $form->element('text')->name('foo')->default($value);

$e->deflator('Strftime')->strftime('%d/%m/%Y');

like( $form->get_field('foo'), qr!31/12/2006! );
