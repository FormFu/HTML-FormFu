use strict;
use warnings;

use Test::More tests => 11;

use HTML::FormFu::MultiForm;

# submit form 1

my $yaml_file = 't/multiform-nested-name/multiform.yml';
my $form2_hidden_value;

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process( {
            foo         => 'abc',
            'block.foo' => '123',
            submit      => 'Submit',
        } );

    ok( $multi->current_form->submitted_and_valid );

    my $form2 = $multi->next_form;

    my $hidden_field = $form2->get_field( { name => 'crypt' } );

    $form2_hidden_value = $hidden_field->default;
}

# submit form 2

my $form3_hidden_value;

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process( {
            crypt       => $form2_hidden_value,
            bar         => 'def',
            'block.bar' => '456',
            submit      => 'Submit',
        } );

    my $form = $multi->current_form;

    ok( $form->submitted_and_valid );

    my $form3 = $multi->next_form;

    my $hidden_field = $form3->get_field( { name => 'crypt' } );

    $form3_hidden_value = $hidden_field->default;
}

# submit form 3

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process( {
            crypt       => $form3_hidden_value,
            baz         => 'ghi',
            'block.baz' => '789',
            submit      => 'Submit',
        } );

    ok( $multi->complete );

    my $form = $multi->current_form;

    ok( $form->submitted_and_valid );

    my $params = $form->params;

    is( $params->{foo},        'abc' );
    is( $params->{block}{foo}, '123' );
    is( $params->{bar},        'def' );
    is( $params->{block}{bar}, '456' );
    is( $params->{baz},        'ghi' );
    is( $params->{block}{baz}, '789' );
    is( $params->{submit},     'Submit' );
}

