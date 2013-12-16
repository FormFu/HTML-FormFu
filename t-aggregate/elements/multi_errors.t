use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new( {
        elements => [ {
                type     => 'Multi',
                label    => 'My multi',
                elements => [ {
                        type => 'Text',
                        name => 'foo',
                    },
                    {   type => 'Radio',
                        name => 'bar',
                    }
                ],
            },
            { type => 'Submit' },
        ],
        constraints => ['Required'],
    } );

$form->tt_args( { INCLUDE_PATH => 'share/templates/tt/xhtml' } );
$form->indicator( sub {1} );
$form->process( {} );

my $xhtml = <<EOF;
<form action="" method="post">
<div class="multi label error error_constraint_required">
<span class="error_message error_constraint_required">This field is required</span>
<span class="error_message error_constraint_required">This field is required</span>
<label>My multi</label>
<span class="elements">
<input name="foo" type="text" />
<input name="bar" type="radio" value="1" />
</span>
</div>
<div class="submit">
<input type="submit" />
</div>
</form>
EOF

is( "$form", $xhtml );

