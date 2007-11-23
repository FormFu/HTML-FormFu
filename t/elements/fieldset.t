use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $outer = $form->element('Fieldset')->name('outer')->legend('My Form');
is( $outer->name, 'outer' );
is( $outer->type, 'Fieldset' );

my $inner = $outer->element('Block');
ok( !$inner->name );
is( $inner->type, 'Block' );

my $foo = $outer->element('Text')->name('foo');
is( $foo->name, 'foo' );
is( $foo->type, 'Text' );

my $field_xhtml = qq{<span class="text">
<input name="foo" type="text" />
</span>};

is( "$foo", $field_xhtml );

my $inner_xhtml = qq{<div>
</div>};

is( "$inner", $inner_xhtml );

my $outer_xhtml = qq{<fieldset>
<legend>My Form</legend>
$inner_xhtml
$field_xhtml
</fieldset>};

is( "$outer", $outer_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
$outer_xhtml
</form>
EOF

is( "$form", $form_xhtml );

