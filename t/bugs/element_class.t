use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

=pod

The input class was getting " text" appended again.
Fixed by cloning the elements in HTML::FormFu::result()

=cut

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

my $xhtml = <<EOF;
<form action="" method="post">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="text">
<input name="bar" type="text" />
</span>
</form>
EOF

# 1st result
{
    $form->process({});
    is( "$form", $xhtml, 'stringified form' );
}

# 2nd result
{
    $form->process({});
    is( "$form", $xhtml, 'stringified form' );
}
