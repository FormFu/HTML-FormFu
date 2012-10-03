use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;

my $form        = HTML::FormFu->new;
my $config_file = 't/elements/label_value_submission.yml';

$form->load_config_file($config_file);

{

    # before 1st render

    $form->default_values( {
            id   => 2,
            name => 'billy bob',
        } );

    is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<input name="id" type="hidden" value="2" />
<div class="label">
<span name="name">billy bob</span>
</div>
<input name="name" type="hidden" value="billy bob" />
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
}

{

    # new form object created to handle form submission

    my $form = HTML::FormFu->new;

    $form->load_config_file($config_file);

    $form->process( {
            id   => '2',
            name => 'billy bob',
        } );

    is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<input name="id" type="hidden" value="2" />
<div class="label">
<span name="name">billy bob</span>
</div>
<input name="name" type="hidden" value="billy bob" />
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
}

{

    # check that a submitted value isn't used by the Label element
    # when there's no other field with the same name in the form

    my $form = HTML::FormFu->new;

    $form->load_config_file($config_file);

    my $hidden = $form->get_field( {
            type => 'Hidden',
            name => 'name',
        } );

    $hidden->parent->remove_element($hidden);

    $form->process( {
            id   => '2',
            name => 'billy bob',
        } );

    ok( $form->submitted_and_valid );

    ok( !$form->valid('name') );
}
