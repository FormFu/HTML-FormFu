use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $foo = $form->element('Checkbox')->name('foo')->value('foox');

# add more elements to test accessor output
my $bar = $form->element('Checkbox')->name('bar')->value('barx');
my $moo
    = $form->element('Checkbox')->name('moo')->value('moox')->default('moox');
my $fad
    = $form->element('Checkbox')->name('fad')->value('fadx')->default('fadx');

my $field_xhtml = qq{<div class="checkbox">
<input name="foo" type="checkbox" value="foox" />
</div>};

is( "$foo", $field_xhtml, 'field xhtml' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<div class="checkbox">
<input name="bar" type="checkbox" value="barx" />
</div>
<div class="checkbox">
<input name="moo" type="checkbox" value="moox" checked="checked" />
</div>
<div class="checkbox">
<input name="fad" type="checkbox" value="fadx" checked="checked" />
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

    like( "$foo", qr/checked/ );
    unlike( "$bar", qr/checked/ );
    like( "$moo", qr/checked/ );
    unlike( "$fad", qr/checked/ );
}
