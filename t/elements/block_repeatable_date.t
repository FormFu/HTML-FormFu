use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/block_repeatable_date.yml');

my $fs = $form->get_element;
my $repeatable = $fs->get_element;

my $return = $repeatable->repeat(1);

my $html = "$form";

# check fields get their names munged

like( $html, qr/select name="foo_day"/ );
like( $html, qr/select name="foo_month"/ );
like( $html, qr/select name="foo_year"/ );
