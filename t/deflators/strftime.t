#!/usr/bin/perl

use HTML::FormFu;
use Test::More qw(no_plan);
use POSIX;

my $f = new HTML::FormFu;

$f->load_config_file('t/deflators/strftime.yml');

use DateTime;

my $now = DateTime->now;

$f->get_all_element({type => "Text"})->default($now);
  
my $loc = $now->strftime('%X %x');

like($f->render, qr/\Q$loc\E/, "localized datetime found");

my $locale = setlocale(LC_TIME);

SKIP: {
  skip if($locale eq "de_DE");
  $f->locale( "de_DE" );
  eval { $now->set_locale("de_DE") };
  skip if $@;
  $loc = $now->strftime('%X %x');
  like($f->render, qr/\Q$loc\E/, "localized german datetime found");

}

