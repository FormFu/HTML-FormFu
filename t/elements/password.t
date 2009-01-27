use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Password')->name('foo');

my $field_xhtml = qq{<div class="password">
<input name="foo" type="password" />
</div>};

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
