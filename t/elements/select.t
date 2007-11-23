use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Select')->name('foo')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

# add more elements to test accessor output
$form->element('Select')->name('foo2')->options( [
        { label => 'Ein',  value => 1 },
        { label => 'Zwei', value => 2, attributes => { class => 'foobar' } },
    ] );
$form->element('Select')->name('bar')->values( [qw/ one two three /] )
    ->value('two')->label('Bar')->attrs( { id => 'bar' } );

my $field_xhtml = qq{<span class="select">
<select name="foo">
<option value="1">One</option>
<option value="2">Two</option>
</select>
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="select">
<select name="foo2">
<option value="1">Ein</option>
<option value="2" class="foobar">Zwei</option>
</select>
</span>
<span class="select label">
<label for="bar">Bar</label>
<select name="bar" id="bar">
<option value="one">One</option>
<option value="two" selected="selected">Two</option>
<option value="three">Three</option>
</select>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process( { bar => 'three', } );

    my $bar_xhtml = qq{<span class="select label">
<label for="bar">Bar</label>
<select name="bar" id="bar">
<option value="one">One</option>
<option value="two">Two</option>
<option value="three" selected="selected">Three</option>
</select>
</span>};

    my $bar = $form->get_field('bar');

    is( "$bar", $bar_xhtml );
}
