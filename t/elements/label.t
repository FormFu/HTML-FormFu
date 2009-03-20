use strict;
use warnings;

use HTML::FormFu;
use Test::More qw(tests 2);

my $f = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$f->load_config_file('t/elements/label.yml');

$f->process;

like($f->render, qr/<span name="foo"><\/span>/, "element found");

like($f->render, qr/<div name="foo3">bar<\/div>/, "element with value and different tag found");


