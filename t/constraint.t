use strict;
use warnings;

use Test::More tests => 40;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

my @c1 = $form->constraint( {
        type  => 'Number',
        names => [qw/ foo bar /],
    } );

is( $c1[0]->name, 'foo' );
is( $c1[0]->type, 'Number' );

is( $c1[1]->name, 'bar' );
is( $c1[1]->type, 'Number' );

{
    my @a = $form->constraint( [ {
                type  => 'Regex',
                names => [qw/ foo bar /],
            },
            {   type  => 'Required',
                names => 'bar',
            },
        ] );

    is( $a[0]->name, 'foo' );
    is( $a[0]->type, 'Regex' );

    is( $a[1]->name, 'bar' );
    is( $a[1]->type, 'Regex' );

    is( $a[2]->name, 'bar' );
    is( $a[2]->type, 'Required' );
}

# $element->constraint
my $ec_element = $form->element('Text')->name('ec');

$ec_element->constraint('Regex')->regex(qr/^\d+$/);

# Valid
{
    $form->process( {
            foo => 1,
            bar => 2,
            ec  => 3,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('ec'),  'ec valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'ec' } $form->valid );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => 'baz',
            ec  => 'a',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( !$form->valid('ec'),  'ec not valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
    ok( !grep { $_ eq 'ec' } $form->valid );
}

# Empty string Valid
{
    $form->process( {
            foo => '',
            bar => 2,
            ec  => '',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('ec'),  'ec not valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'ec' } $form->valid );
}

# Missing Invalid
{
    $form->process( {
            foo => '',
            bar => 2,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( !$form->valid('ec'), 'ec not valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( grep  { $_ eq 'bar' } $form->valid );
    ok( !grep { $_ eq 'ec' } $form->valid );
}

# zero "0" Valid
{
    $form->process( {
            foo => 0,
            bar => 1,
            ec  => 0,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('ec'),  'ec valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'ec' } $form->valid );
}
