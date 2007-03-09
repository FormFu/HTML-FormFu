use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use Storable qw/ dclone /;

my $form = HTML::FormFu->new;

my $fs = $form->element('fieldset');
my $e1 = $fs->element('text')->name('foo');
my $e2 = $fs->element('hidden')->name('foo');

my $e3 = $e1->clone;

$fs->insert_after( $e3, $e2 );

my $elems = $fs->get_elements;

is( $elems->[0], $e1 );
is( $elems->[1], $e2 );
is( $elems->[2], $e3 );
