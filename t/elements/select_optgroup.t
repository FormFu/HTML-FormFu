use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Select')->name('foo')->value(2)->options( [
        { group => [ [ 1 => 'one' ], [ 2 => 'two' ] ] },
        {   group => [ [ foo2_1 => 'One' ], [ foo2_2 => 'Two' ] ],
            label => 'foo2',
        },
        [ x => 'non-opt' ],
        {   group => [
                { label => 'wun', value => 'foo3_1' },
                {   label      => 'too',
                    value      => 'foo3_2',
                    attributes => { class => 'foo3b' } }
            ],
            label      => 'foo3',
            attributes => { class => 'opt4' },
        },
    ] );

my $form_xhtml = <<EOF;
<form action="" method="post">
<span class="select">
<select name="foo">
<optgroup>
<option value="1">one</option>
<option value="2" selected="selected">two</option>
</optgroup>
<optgroup label="foo2">
<option value="foo2_1">One</option>
<option value="foo2_2">Two</option>
</optgroup>
<option value="x">non-opt</option>
<optgroup label="foo3" class="opt4">
<option value="foo3_1">wun</option>
<option value="foo3_2" class="foo3b">too</option>
</optgroup>
</select>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

# With mocked basic query
{
    $form->process( { foo => 'foo2_1', } );

    my $foo = $form->get_field('foo');

    like( "$foo", qr/value="foo2_1" selected="selected"/ );

    my $count = $foo =~ s/selected="selected"/selected="selected"/g;

    is( $count, 1 );
}
