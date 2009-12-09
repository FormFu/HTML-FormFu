use strict;
use warnings;

use Test::More tests => 18;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/get_parent.yml');

$form->get_all_element({ type => 'Repeatable' })->repeat(2);

$form->process;

my $fieldset = $form->get_element;
is( $fieldset->type, 'Fieldset' );

my $block_1 = $fieldset->get_element;
is( $block_1->name, 'block_1' );

my $block_1_1 = $block_1->get_element;
is( $block_1_1->name, 'block_1_1' );

my $text_1_1_1 = $block_1_1->get_element;
is( $text_1_1_1->name, 'text_1_1_1' );

my $repeatable = $block_1->get_elements->[1];
is( $repeatable->name, 'repeatable_1_2' );

my $rep_1 = $repeatable->get_element;
is( $rep_1->type, 'Block' );

my $rep_text_1 = $rep_1->get_element;
is( $rep_text_1->name, 'rep_text_1' );

my $rep_2 = $repeatable->get_elements->[1];
is( $rep_2->type, 'Block' );

my $rep_text_2 = $rep_2->get_element;
is( $rep_text_2->name, 'rep_text_2' );

my $submit_2 = $fieldset->get_elements->[1];
is( $submit_2->name, 'submit_2' );

###

ok( $text_1_1_1->get_parent() eq $block_1_1 );

ok( $text_1_1_1->get_parent({ tag => 'span' }) eq $block_1_1 );

ok( $text_1_1_1->get_parent({ tag => 'div' }) eq $block_1 );

ok( $text_1_1_1->get_parent({ type => 'Fieldset' }) eq $fieldset );

###

ok( $rep_1->get_parent({ type => 'Repeatable' }) eq $repeatable );

ok( $rep_2->get_parent({ type => 'Repeatable' }) eq $repeatable );

ok( !defined $rep_2->get_parent({ type => 'Unknown' }) );
ok( !defined $rep_2->get_parent({ foo => 'bar' }) );
