#!/usr/bin/perl

use HTML::FormFu;
use Test::More qw(no_plan);
use Number::Format;

# This test is pretty hard to write
# you cannot know which locales are installed on a system
# and how the result should look like for every locale
# I simply check here whether the number has been transformed
# in any way. Inflation is tested by comparing the string to
# a perl number.


my $f = new HTML::FormFu(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$f->load_config_file('t/elements/number.yml');

$f->get_all_element({type => "Number"})->default('10002300.123');

$f->process;

unlike($f->render, qr/10002300.123/, "exact number not there");

my $foo = Number::Format->new->format_number(23000222.22);
$f->process({foo => $foo}); 

ok($f->submitted_and_valid, "number constraint");

is($f->param('foo'), 23000222.22, "is number");


