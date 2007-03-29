use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('password')->name('foo');

my $field_xhtml = qq{<span class="password">
<input name="foo" type="password" />
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process( { foo => 'yada', } );

    like( $form->get_field('foo'), qr/value=""/ );
}
