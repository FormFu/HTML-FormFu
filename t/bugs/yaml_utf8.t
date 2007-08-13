use strict;
use warnings;
use Encode 'encode';

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new->load_config_file('t/bugs/yaml_utf8.yml');

open my $fh, '<:encoding(UTF-8)', 't/bugs/yaml_utf8.txt'
    or die $!;

my $text = do { local $/; <$fh> };
chomp $text;

is( $form->get_field('foo')->label, $text );

