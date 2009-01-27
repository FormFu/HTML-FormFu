use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Radio')->name('foo')->value('foox');

# add more elements to test accessor output
$form->element('Radio')->name('bar')->value('barx');
$form->element('Radio')->name('moo')->value('moox')->checked('checked');
$form->element('Radio')->name('fad')->value('fadx')->checked('checked');

my $field_xhtml = qq{<div class="radio">
<input name="foo" type="radio" value="foox" />
</div>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<div class="radio">
<input name="bar" type="radio" value="barx" />
</div>
<div class="radio">
<input name="moo" type="radio" value="moox" checked="checked" />
</div>
<div class="radio">
<input name="fad" type="radio" value="fadx" checked="checked" />
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process( {
            foo => 'foox',
            moo => 'moox',
        } );

    like( $form->get_field('foo'), qr/checked/ );
    unlike( $form->get_field('bar'), qr/checked/ );
    like( $form->get_field('moo'), qr/checked/ );
    unlike( $form->get_field('fad'), qr/checked/ );
}
