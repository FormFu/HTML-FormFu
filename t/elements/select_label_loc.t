use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({
    localize_class => 'HTMLFormFu::I18N',
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
});

{
    my $field = $form->element('Select')->name('foo');
    $field->options([
    {
        label_loc => 'label_foo',
        value     => 'foo',
    }
    ]);

    my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="foo">Foo label</option>
</select>
</div>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}
