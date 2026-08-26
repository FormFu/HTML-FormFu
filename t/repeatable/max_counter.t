use strict;
use warnings;

use Test::More tests => 13;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

# Test that max_counter defaults to 100 and clamps large values
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );

    is( $repeatable->max_counter, 100, 'default max_counter is 100' );

    $form->process( { count => 200 } );

    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 100, '200 repeats clamped to 100' );
    ok( $repeatable->counter_clamped, 'counter_clamped is true after clamping' );
}

# Test that max_counter can be set lower
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );
    $repeatable->max_counter(5);

    $form->process( { count => 10 } );

    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 5, '10 repeats clamped to 5' );
    ok( $repeatable->counter_clamped, 'counter_clamped is true' );
}

# Test that max_counter=0 means unlimited (not clamped)
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );
    $repeatable->max_counter(0);

    $form->process( { count => 3 } );

    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 3, 'max_counter=0 allows 3 repeats unclamped' );
    ok( !$repeatable->counter_clamped, 'counter_clamped is false' );
}

# Test that normal small values are unaffected
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    $form->process( { count => 3 } );

    my $repeatable = $form->get_element( { type => 'Repeatable' } );
    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 3, '3 repeats below default max_counter' );
    ok( !$repeatable->counter_clamped, 'counter_clamped is false' );
}

# Test that calling repeat() directly is unaffected by max_counter
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );
    $repeatable->repeat(200);

    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 200, 'direct repeat(200) unaffected by max_counter' );
}

# Test form-level repeatable_max_counter
{
    my $form = HTML::FormFu->new(
        {   tt_args               => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
            repeatable_max_counter => 50,
        } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );

    is( $repeatable->max_counter, 50,
        'max_counter inherits form repeatable_max_counter' );

    $form->process( { count => 200 } );

    my @blocks = @{ $repeatable->get_elements };
    is( scalar @blocks, 50, '200 clamped to form-level 50' );
}

# Test chained method works
{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/repeatable/max_counter.yml');

    my $repeatable = $form->get_element( { type => 'Repeatable' } );

    $repeatable->max_counter(10)->max_counter(20);

    is( $repeatable->max_counter, 20, 'chained max_counter setter works' );
}
