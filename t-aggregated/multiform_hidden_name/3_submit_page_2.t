use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu::MultiForm;

# submit form 1

my $yaml_file = 't-aggregated/multiform_hidden_name/multiform.yml';
my $form2_hidden_value;

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process( {
            foo    => 'abc',
            submit => 'Submit',
        } );

    ok( $multi->current_form->submitted_and_valid );

    my $form2 = $multi->next_form;

    my $hidden_field = $form2->get_field( { name => 'crypt' } );

    $form2_hidden_value = $hidden_field->default;
}

# submit form 2

{
    my $multi = HTML::FormFu::MultiForm->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

    $multi->load_config_file($yaml_file);

    $multi->process( {
            crypt  => $form2_hidden_value,
            bar    => 'def',
            submit => 'Submit',
        } );

    my $form = $multi->current_form;

    ok( $form->submitted_and_valid );

    my $params = $form->params;

    is( $params->{foo},    'abc' );
    is( $params->{bar},    'def' );
    is( $params->{submit}, 'Submit' );

    # does form 3 render ok?

    like( "$multi", qr|<input name="baz" type="text" />| );
}

