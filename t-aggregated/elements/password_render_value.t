use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Password')->name('foo')->render_value(1);

my $field_xhtml = qq{<div class="password">
<input name="foo" type="password" />
</div>};

is( $form->get_field('foo'), $field_xhtml );

# With mocked basic query
{
    $form->process( { foo => 'yada', } );

    my $field_xhtml = qq{<div class="password">
<input name="foo" type="password" value="yada" />
</div>};

    is( $form->get_field('foo'), $field_xhtml );
}
