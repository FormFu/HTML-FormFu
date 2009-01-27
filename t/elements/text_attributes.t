use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $element
    = $form->element('Text')->name('foo')->comment('Whatever')->label('Foo')
    ->default('bar')->size(30)->maxlength(50);

is( $element->name,      'foo',      'element name' );
is( $element->type,      'Text',     'element type' );
is( $element->comment,   'Whatever', 'element comment' );
is( $element->label,     'Foo',      'element label' );
is( $element->default,   'bar',      'element value' );
is( $element->size,      30,         'element size' );
is( $element->maxlength, 50,         'element maxlength' );
is_deeply(
    $element->attributes,
    {   size      => 30,
        maxlength => 50,
    },
    'element attributes',
);

# add more elements to test accessor output
$form->element('Text')->name('bar')->container_attributes( { class => 'bar' } );

my $expected_field_xhtml = qq{<div class="text comment label">
<label>Foo</label>
<input name="foo" type="text" value="bar" maxlength="50" size="30" />
<span class="comment">
Whatever
</span>
</div>};

is( "$element", $expected_field_xhtml, 'stringified field' );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
$expected_field_xhtml
<div class="bar text">
<input name="bar" type="text" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml, 'stringified form' );

