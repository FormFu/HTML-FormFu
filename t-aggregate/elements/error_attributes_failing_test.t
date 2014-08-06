use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t-aggregate/elements/error_attributes_failing_test.text-with-attrs.yml');

    $form->process({
        foo => 3333,
    });

    is( "$form", <<EOF );
<form action="" method="post">
<div>
<span class="class-error_attributes">test</span>
<label>Foo</label>
<input name="foo" type="text" value="3333" />
</div>
</form>
EOF
}

{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->default_args({
        elements => {
            Field => {
                error_attributes => {
                    class => 'class-error_attributes',
                },
                attributes => {
                    class => 'class-attributes', # used in the error_tag!
                },
            },
            layout => [qw/label errors field comment javascript/],
        },
    });


    $form->load_config_file('t-aggregate/elements/error_attributes_failing_test.text.yml');

    $form->process({
        foo => 3333,
    });

    is( "$form", <<EOF );
<form action="" method="post">
<div>
<span class="class-error_attributes">test</span>
<label>Foo</label>
<input name="foo" type="text" value="3333" class="class-attributes" />
</div>
</form>
EOF
}

{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t-aggregate/elements/error_attributes_failing_test.select-with-attrs.yml');

    $form->process({
        foo => 3333,
    });

    is( "$form", <<EOF );
<form action="" method="post">
<div>
<span class="class-error_attributes">test</span>
<select name="foo">
<option value="1">One</option>
<option value="2">Two</option>
</select>
</div>
</form>
EOF
}

{
    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->default_args({
        elements => {
            Field => {
                error_attributes => {
                    class => 'class-error_attributes',
                },
                attributes => {
                    class => 'class-attributes',
                },
            },
            layout => [qw/label errors field comment javascript/],
        },
    });

    $form->load_config_file('t-aggregate/elements/error_attributes_failing_test.select.yml');

    $form->process({
        foo => 3333,
    });

    is( "$form", <<EOF );
<form action="" method="post">
<div>
<span class="class-error_attributes">test</span>
<select name="foo" class="class-attributes">
<option value="1">One</option>
<option value="2">Two</option>
</select>
</div>
</form>
EOF
}
