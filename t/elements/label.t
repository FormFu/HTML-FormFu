#!/usr/bin/perl

use HTML::FormFu;
use Test::More qw(tests 2);


my $f = new HTML::FormFu;

$f->elements({type => "Label", name => "foo"});

$f->process;

like($f->render, qr/<span name="foo"><\/span>/, "element found");

$f->elements({type => "Label", name => "foo3", value => "bar", tag => "div"});

like($f->render, qr/<div name="foo3">bar<\/div>/, "element with value and different tag found");


