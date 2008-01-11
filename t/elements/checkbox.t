use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('Checkbox')->name('foo')->value('foox');

# add more elements to test accessor output
my $bar = $form->element('Checkbox')->name('bar')->value('barx');
my $moo
    = $form->element('Checkbox')->name('moo')->value('moox')->default('moox');
my $fad
    = $form->element('Checkbox')->name('fad')->value('fadx')->default('fadx');

my $field_xhtml = qq{<span class="checkbox">
<input name="foo" type="checkbox" value="foox" />
</span>};

is( "$foo", $field_xhtml, 'field xhtml' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="checkbox">
<input name="bar" type="checkbox" value="barx" />
</span>
<span class="checkbox">
<input name="moo" type="checkbox" value="moox" checked="checked" />
</span>
<span class="checkbox">
<input name="fad" type="checkbox" value="fadx" checked="checked" />
</span>
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
