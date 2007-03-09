use strict;
use warnings;

use Test::More tests => 22;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

$form->constraint( 'Number', 'foo', 'bar' );

$form->process( {
        foo => 1,
        bar => 'a',
    } );

{
    is( $form->param('foo'), 1 );
    ok( !$form->valid('bar') );

    my $errors = $form->errors;

    ok( @$errors == 1 );

    is( $errors->[0]->name, 'bar' );
    is( $errors->[0]->type, 'Number' );
}

$form->add_error('foo');

{
    ok( !$form->valid('foo') );
    ok( !$form->valid('bar') );

    my $errors = $form->errors;

    ok( @$errors == 2 );

    is( $errors->[0]->name, 'bar' );
    is( $errors->[0]->type, 'Number' );

    is( $errors->[1]->name, 'foo' );
    is( $errors->[1]->type, 'Custom' );
}

$form->add_error( {
        name    => 'bar',
        type    => 'Boom',
        message => 'Bad value',
    } );

{
    ok( !$form->valid('foo') );
    ok( !$form->valid('bar') );

    my $errors = $form->errors;

    ok( @$errors == 3 );

    is( $errors->[0]->name, 'bar' );
    is( $errors->[0]->type, 'Number' );

    is( $errors->[1]->name,    'bar' );
    is( $errors->[1]->type,    'Boom' );
    is( $errors->[1]->message, 'Bad value' );

    is( $errors->[2]->name, 'foo' );
    is( $errors->[2]->type, 'Custom' );
}

