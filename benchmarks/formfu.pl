use strict;
use warnings;
use Benchmark qw( cmpthese );
use lib 'lib';
use HTML::FormFu;

my $form_tt = HTML::FormFu->new;
$form_tt->load_config_file('test.yml');
$form_tt->tt_args({
    COMPILE_DIR    => 'benchmarks/cache',
    COMPILE_EXT    => '.tt_cache',
    INCLUDE_PATH   => 'share/templates/tt/xhtml',
    });

my $form_tt_alloy = HTML::FormFu->new;
$form_tt_alloy->load_config_file('test.yml');
$form_tt_alloy->tt_module('Template::Alloy');
$form_tt_alloy->tt_args({
    TEMPLATE_ALLOY => 1,
    COMPILE_DIR    => 'benchmarks/cache',
    COMPILE_PERL   => 1,
    INCLUDE_PATH   => 'share/templates/tt/xhtml',
    });

my $form_tt_alloy_xs = HTML::FormFu->new;
$form_tt_alloy_xs->load_config_file('test.yml');
$form_tt_alloy_xs->tt_module('Template::Alloy::XS');
$form_tt_alloy_xs->tt_args({
    TEMPLATE_ALLOY => 1,
    COMPILE_DIR    => 'benchmarks/cache',
    COMPILE_PERL   => 1,
    INCLUDE_PATH   => 'share/templates/tt/xhtml',
    });

my $form_string = HTML::FormFu->new;
$form_string->load_config_file('test.yml');
$form_string->render_method('string');

my $baseline = "$form_string";

die "forms differ" if "$form_tt"           ne $baseline;
die "forms differ" if "$form_tt_alloy"    ne $baseline;
die "forms differ" if "$form_tt_alloy_xs" ne $baseline;

my $html;

cmpthese( 100, {
    tt => sub {
        $html = "$form_tt";
    },
    template_alloy => sub {
        $html = "$form_tt_alloy";
    },
    template_alloy_xs => sub {
        $html = "$form_tt_alloy_xs";
    },
    string => sub {
        $html = "$form_string";
    },
});
