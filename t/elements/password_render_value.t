use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('password')->name('foo')->render_value(1);

my $field_xhtml = qq{<span class="password">
<input name="foo" type="password" />
</span>};

is( $form->get_field('foo'), $field_xhtml );

# With mocked basic query
{
    $form->process( { foo => 'yada', } );

    my $field_xhtml = qq{<span class="password">
<input name="foo" type="password" value="yada" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
}
