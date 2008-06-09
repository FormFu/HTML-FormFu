use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $date = $form->element('Date')->name('foo');

$form->process;

# change name

$date->name('bar');

$form->process;

like( "$form", qr/name="bar_day"/ );
