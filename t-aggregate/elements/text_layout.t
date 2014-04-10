use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t-aggregate/elements/text_layout.yml');

###

is( $form, <<HTML, 'default layout' );
<form action="" id="form" method="post">
<div>
<label for="form_foo">Foo</label>
<input name="foo" type="text" id="form_foo" />
<span>
The foo
</span>
</div>
</form>
HTML

my $foo = $form->get_field({ name => 'foo' });

###

$foo->layout( {
    label => [
        'field',
        'label_text',
    ],
} );

is( $form, <<HTML, 'label tag contains both input tag and label text' );
<form action="" id="form" method="post">
<div>
<label for="form_foo">
<input name="foo" type="text" id="form_foo" />
Foo
</label>
</div>
</form>
HTML

###

$foo->layout( [
    'label',
    {
        div => {
            attributes => {
                class => 'xxx'
            },
            content => 'field'
        },
    },
] );

is( $form, <<HTML, 'arbitrary div with attributes containing input tag' );
<form action="" id="form" method="post">
<div>
<label for="form_foo">Foo</label>
<div class="xxx">
<input name="foo" type="text" id="form_foo" />
</div>
</div>
</form>
HTML

###

$foo->layout( {
    div => {
        attributes => {
            class => 'xxx',
        },
        content => {
            div => {
                attributes => {
                    class => 'yyy',
                },
                content => {
                    label => [
                        'field',
                        'label_text',
                    ],
                },
            },
        },
    },
} );

is( $form, <<HTML, '2 nested arbitrary divs with attributes, containing label tag containing input tag and label text' );
<form action="" id="form" method="post">
<div>
<div class="xxx">
<div class="yyy">
<label for="form_foo">
<input name="foo" type="text" id="form_foo" />
Foo
</label>
</div>
</div>
</div>
</form>
HTML

