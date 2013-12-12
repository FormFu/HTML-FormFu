use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

my $field1 = $form->element('Radiogroup')->name('foo')->value(2)
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

# add element to test non-reversed labels
my $field2 = $form->element('Radiogroup')->name('foo2')
    ->options( [ [ 'a' => 'A' ], [ 'b' => 'B' ] ] )->reverse_group(0);

# add more elements to test accessor output
$form->element('Radiogroup')->name('foo3')->options( [
        { label => 'Ein', value => 1 },
        {   label                => 'Zwei',
            value                => 2,
            attributes           => { class => 'foobar' },
            container_attributes => { class => 'item 2' }
        },
    ] );

$form->element('Radiogroup')->name('bar')->values( [qw/ one two three /] )
    ->value('two')->label('My Bar');

$form->process;

my $field1_xhtml = qq{<fieldset class="radiogroup">
<span>
<span>
<input name="foo" type="radio" value="1" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="2" checked="checked" />
<label>Two</label>
</span>
</span>
</fieldset>};

is( "$field1", $field1_xhtml, 'basic radiogroup' );

my $field2_xhtml = qq{<fieldset class="radiogroup">
<span>
<span>
<label>A</label>
<input name="foo2" type="radio" value="a" />
</span>
<span>
<label>B</label>
<input name="foo2" type="radio" value="b" />
</span>
</span>
</fieldset>};

is( "$field2", $field2_xhtml, 'radiogroup with reverse_group off' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field1_xhtml
$field2_xhtml
<fieldset class="radiogroup">
<span>
<span>
<input name="foo3" type="radio" value="1" />
<label>Ein</label>
</span>
<span class="item 2">
<input name="foo3" type="radio" value="2" class="foobar" />
<label>Zwei</label>
</span>
</span>
</fieldset>
<fieldset class="radiogroup">
<legend>My Bar</legend>
<span>
<span>
<input name="bar" type="radio" value="one" />
<label>One</label>
</span>
<span>
<input name="bar" type="radio" value="two" checked="checked" />
<label>Two</label>
</span>
<span>
<input name="bar" type="radio" value="three" />
<label>Three</label>
</span>
</span>
</fieldset>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process( {
            foo => 1,
            bar => 'three',
        } );

    my $foo_xhtml = qq{<fieldset class="radiogroup">
<span>
<span>
<input name="foo" type="radio" value="1" checked="checked" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="2" />
<label>Two</label>
</span>
</span>
</fieldset>};

    is( $form->get_field('foo'), $foo_xhtml, 'radiogroup after query' );

    my $bar_xhtml = qq{<fieldset class="radiogroup">
<legend>My Bar</legend>
<span>
<span>
<input name="bar" type="radio" value="one" />
<label>One</label>
</span>
<span>
<input name="bar" type="radio" value="two" />
<label>Two</label>
</span>
<span>
<input name="bar" type="radio" value="three" checked="checked" />
<label>Three</label>
</span>
</span>
</fieldset>};

    is( $form->get_field('bar'), $bar_xhtml, 'second radiogroup after query' );
}
