use strict;
use warnings;

use Test::More tests => 14;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('string');

$form->constraint( 'Number', 'foo', 'bar', 'string' );

$form->process( {
        foo    => 1,
        bar    => [ 2, 'c' ],
        string => 'yada',
    } );

{
    my $errors = $form->get_errors;

    is( @$errors, 2 );
}

{
    my $errors = $form->get_errors('bar');

    is( @$errors, 1 );

    is( $errors->[0]->name,    'bar' );
    is( $errors->[0]->message, 'This field must be a number' )
}

{
    my $errors = $form->get_errors( { name => 'string' } );

    is( @$errors, 1 );

    is( $errors->[0]->name, 'string' );
}

{
    my $errors = $form->get_errors( { type => 'Number' } );

    is( @$errors, 2 );

    is( $errors->[0]->name, 'bar' );
    is( $errors->[1]->name, 'string' );
}

{
    my $errors = $form->get_errors( {
            name => 'bar',
            type => 'Number',
        } );

    is( @$errors, 1 );

    is( $errors->[0]->name,  'bar' );
    is( $errors->[0]->type,  'Number' );
    is( $errors->[0]->stage, 'constraint' );

    my $xhtml = qq{<span class="text error error_constraint_number">
<span class="error_message error_constraint_number">This field must be a number</span>
<input name="bar" type="text" value="2" />
</span>};

    is( $form->get_field('bar'), $xhtml );
}

