use strict;
use warnings;

use Test::More tests => 13;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/constraints/required_not_increment_field_names.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            foo => ['a', 'b'],
            bar => ['c', 'd'],
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {
            foo => ['a', 'b'],
            bar => ['c', 'd'],
            count => 2,
        } );
}

# Missing - Invalid
{
    $form->process( {
            foo => ['', 'b'],
            bar => ['c', ''],
            count => 2,
        } );

    ok( !$form->submitted_and_valid );

    # $form->has_errors() doesn't really make sense for multiple fields with the same name
    # -  an error on any of those fields will return true

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );

    my $foo1 = $form->get_fields('foo')->[0];
    my $foo2 = $form->get_fields('foo')->[1];
    my $bar1 = $form->get_fields('bar')->[0];
    my $bar2 = $form->get_fields('bar')->[1];

    is( scalar @{ $foo1->get_errors }, 1 );
    is( scalar @{ $foo2->get_errors }, 0 );
    is( scalar @{ $bar1->get_errors }, 0 );
    is( scalar @{ $bar2->get_errors }, 1 );

    like( $foo1, qr/error/ );
    unlike( $foo2, qr/error/ );

    unlike( $bar1, qr/error/ );
    like( $bar2, qr/error/ );
}
