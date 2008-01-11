use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Checkboxgroup')->name('foo')->value(2)
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

# add more elements to test accessor output
$form->element('Checkboxgroup')->name('foo2')->options( [
        { label => 'Ein',  value => 1 },
        { label => 'Zwei', value => 2, attributes => { class => 'foobar' } },
    ] );
$form->element('Checkboxgroup')->name('bar')->values( [qw/ one two three /] )
    ->value('two')->label('My Bar');

my $field_xhtml = qq{<fieldset class="checkboxgroup">
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

is( "$field", $field_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<fieldset class="checkboxgroup">
<span>
<span>
<input name="foo2" type="checkbox" value="1" />
<label>Ein</label>
</span>
<span>
<input name="foo2" type="checkbox" value="2" class="foobar" />
<label>Zwei</label>
</span>
</span>
</fieldset>
<fieldset class="checkboxgroup legend">
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

is( "$form", $form_xhtml );

# With mocked basic query
{
    $form->process( {
            foo => [ 1, 2, ],
            bar => 'three',
        } );

    my $foo_xhtml = qq{<fieldset class="checkboxgroup">
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

    is( $form->get_field('foo'), $foo_xhtml );

    my $bar_xhtml = qq{<fieldset class="checkboxgroup legend">
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

    is( $form->get_field('bar'), $bar_xhtml );
}
