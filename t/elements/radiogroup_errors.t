use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->indicator( sub {1} );

my $field = $form->element('radiogroup');

$field->name('foo');
$field->values([qw/ one two /]);
$field->label('My legend');
$field->constraint('Required');

my $xhtml = qq{<fieldset class="radiogroup legend">
<legend>My legend</legend>
<span>
<span>
<input name="foo" type="radio" value="one" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="two" />
<label>Two</label>
</span>
</span>
</fieldset>};

is( "$field", $xhtml );

# With mocked basic query
{
    $form->process( {} );

    my $xhtml = qq{<fieldset class="radiogroup legend error error_constraint_required">
<legend>My legend</legend>
<span class="error_message error_constraint_required">This field is required</span>
<span>
<span>
<input name="foo" type="radio" value="one" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="two" />
<label>Two</label>
</span>
</span>
</fieldset>};

    is( "$field", $xhtml );
}
