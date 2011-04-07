use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

ok( my $element = $form->element('Search')->name('foo') );
is( $element->name, 'foo' );
is( $element->type, 'Search' );

# add more elements to test accessor output
$form->element('Search')->name('bar')->size(10);
$form->element('Search')->name('baz')->size(15)->maxlength(20);

my $expected_field_xhtml = qq{<div class="search">
<input name="foo" type="search" />
</div>};

is( "$element", $expected_field_xhtml );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
$expected_field_xhtml
<div class="search">
<input name="bar" type="search" size="10" />
</div>
<div class="search">
<input name="baz" type="search" maxlength="20" size="15" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
