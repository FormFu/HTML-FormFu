use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use Storable qw/ dclone /;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $fs = $form->element('Fieldset');
my $e1 = $fs->element('Text')->name('foo');
my $e2 = $fs->element('Hidden')->name('foo');

my $e3 = $e1->clone;

$fs->insert_after( $e3, $e2 );

my $elems = $fs->get_elements;

is( $elems->[0], $e1 );
is( $elems->[1], $e2 );
is( $elems->[2], $e3 );
