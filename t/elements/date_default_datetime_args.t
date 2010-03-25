use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use DateTime;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/date_default_datetime_args.yml');

$form->process;

# year in `default_datetime_args` overrides year from `default`

my $match_xhtml = qq{<option value="2001" selected="selected">2001</option>};

cmp_ok( $form, '=~', $match_xhtml );
