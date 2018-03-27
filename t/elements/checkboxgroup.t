use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

my $field1 = $form->element('Checkboxgroup')->name('foo')->value(2)
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

# add element to test non-reversed labels
my $field2 = $form->element('Checkboxgroup')->name('foo2')
    ->options( [ [ 'a' => 'A' ], [ 'b' => 'B' ] ] )->reverse_group(0);

# add more elements to test accessor output
$form->element('Checkboxgroup')->name('foo3')->options(
    [   { label => 'Ein',  value => 1 },
        { label => 'Zwei', value => 2, attributes => { class => 'foobar' } },
    ] );
$form->element('Checkboxgroup')->name('bar')->values( [qw/ one two three /] )
    ->value('two')->label('My Bar');

my $field1_xhtml = qq{<fieldset>
<span>
<span>
<input name="foo" type="checkbox" value="1" />
<label>One</label>
</span>
<span>
<input name="foo" type="checkbox" value="2" checked="checked" />
<label>Two</label>
</span>
</span>
</fieldset>};

is( "$field1", $field1_xhtml, 'basic checkboxgroup' );

my $field2_xhtml = qq{<fieldset>
<span>
<span>
<label>A</label>
<input name="foo2" type="checkbox" value="a" />
</span>
<span>
<label>B</label>
<input name="foo2" type="checkbox" value="b" />
</span>
</span>
</fieldset>};

is( "$field2", $field2_xhtml, 'checkboxgroup with reverse_group off' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field1_xhtml
$field2_xhtml
<fieldset>
<span>
<span>
<input name="foo3" type="checkbox" value="1" />
<label>Ein</label>
</span>
<span>
<input name="foo3" type="checkbox" value="2" class="foobar" />
<label>Zwei</label>
</span>
</span>
</fieldset>
<fieldset>
<legend>My Bar</legend>
<span>
<span>
<input name="bar" type="checkbox" value="one" />
<label>One</label>
</span>
<span>
<input name="bar" type="checkbox" value="two" checked="checked" />
<label>Two</label>
</span>
<span>
<input name="bar" type="checkbox" value="three" />
<label>Three</label>
</span>
</span>
</fieldset>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process(
        {   foo => [ 1, 2, ],
            bar => 'three',
        } );

    my $foo_xhtml = qq{<fieldset>
<span>
<span>
<input name="foo" type="checkbox" value="1" checked="checked" />
<label>One</label>
</span>
<span>
<input name="foo" type="checkbox" value="2" checked="checked" />
<label>Two</label>
</span>
</span>
</fieldset>};

    is( $form->get_field('foo'), $foo_xhtml, 'checkboxgroup after query' );

    my $bar_xhtml = qq{<fieldset>
<legend>My Bar</legend>
<span>
<span>
<input name="bar" type="checkbox" value="one" />
<label>One</label>
</span>
<span>
<input name="bar" type="checkbox" value="two" />
<label>Two</label>
</span>
<span>
<input name="bar" type="checkbox" value="three" checked="checked" />
<label>Three</label>
</span>
</span>
</fieldset>};

    is( $form->get_field('bar'),
        $bar_xhtml, 'second checkboxgroup after query' );
}
