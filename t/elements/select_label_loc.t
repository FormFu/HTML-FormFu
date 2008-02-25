use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({
    localize_class => 'HTMLFormFu::I18N',   
});

{
    my $field = $form->element('Select')->name('foo');
    $field->options([
    {
        label_loc => 'label_foo',
        value     => 'foo',
    }
    ]);

    my $field_xhtml = qq{<span class="select">
<select name="foo">
<option value="foo">Foo label</option>
</select>
</span>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}
