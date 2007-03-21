use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->indicator( sub {1} );

my $field = $form->element('radiogroup');

$field->name('foo');
$field->values([qw/ one two /]);
$field->constraint('Required');

my $xhtml = qq{<fieldset class="radiogroup">
<span>
<input name="foo" type="radio" value="one" />
<label>One</label>
<input name="foo" type="radio" value="two" />
<label>Two</label>
</span>
</fieldset>};

is( "$field", $xhtml );

# With mocked basic query
{
    $form->process( {} );

    my $xhtml = qq{<fieldset class="radiogroup error error_constraint_required">
<span class="error_message error_constraint_required">This field is required</span>
<span>
<input name="foo" type="radio" value="one" />
<label>One</label>
<input name="foo" type="radio" value="two" />
<label>Two</label>
</span>
</fieldset>};

    is( "$field", $xhtml );
}
