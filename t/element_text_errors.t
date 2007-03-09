use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('text')->name('foo')->label('My Foo');
my $bar = $form->element('text')->name('bar');

$form->constraint( Number   => 'foo' );
$form->constraint( Word     => 'bar' );
$form->constraint( Required => 'foo', 'bar' );

my $foo_xhtml = qq{<span class="text label">
<label>My Foo</label>
<input name="foo" type="text" />
</span>};

is( "$foo", $foo_xhtml );

my $bar_xhtml = qq{<span class="text">
<input name="bar" type="text" />
</span>};

is( "$bar", $bar_xhtml );

# With mocked basic query
{
    $form->process({ foo => 'yada', });

    $form->add_error('foo');

    my $foo_xhtml = qq{<span class="text error number_error custom_error label">
<span class="error_message number_error">This field must be a number</span>
<span class="error_message custom_error">Invalid input</span>
<label>My Foo</label>
<input name="foo" type="text" value="yada" />
</span>};

    is( "$foo", $foo_xhtml, 'field xhtml' );

    my $bar_xhtml = qq{<span class="text error required_error">
<span class="error_message required_error">This field is required</span>
<input name="bar" type="text" />
</span>};

    is( "$bar", $bar_xhtml, 'field xhtml' );

    my $form_xhtml = <<EOF;
<form action="" method="post">
$foo_xhtml
$bar_xhtml
</form>
EOF

    is( "$form", $form_xhtml, 'form xhtml' );
}
