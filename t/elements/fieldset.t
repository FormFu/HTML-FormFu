use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $outer = $form->element('fieldset')->name('outer')->legend('My Form');
is( $outer->name,         'outer' );
is( $outer->type, 'fieldset' );

my $inner = $outer->element('block');
ok( !$inner->name );
is( $inner->type, 'block' );

my $foo = $outer->element('text')->name('foo');
is( $foo->name,         'foo' );
is( $foo->type, 'text' );

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

