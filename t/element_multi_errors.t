use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({
    element => {
        type => 'multi',
        label => 'My multi',
        elements => [{
            type => 'text',
            name => 'foo',
        },
        {
            type => 'radio',
            name => 'bar',
        }]
        },
    constraints => ['Required'],
    });

$form->indicator( sub {1} );
$form->process({});

my $xhtml = <<EOF;
<form action="" method="post">
<span class="multi label error error_constraint_required">
<span class="error_message error_constraint_required">This field is required</span>
<span class="error_message error_constraint_required">This field is required</span>
<label>My multi</label>
<span class="elements">
<input name="foo" type="text" />
<input name="bar" type="radio" />
</span>
</span>
</form>
EOF

is( "$form", $xhtml );

