use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({
    localize_class => 'HTMLFormFu::I18N',
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
});

{
    my $field = $form->element('Select')->name('foo');
    $field->empty_first(1);
    $field->empty_first_label('empty_label');
    $field->options([ [ 1 => 'One' ], [ 2 => 'Two' ] ]);

    my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="">empty_label</option>
<option value="1">One</option>
<option value="2">Two</option>
</select>
</div>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}

{
    my $field = $form->element('Select')->name('foo');
    $field->empty_first(1);
    $field->empty_first_label('empty_label');
    $field->values([qw/one two/]);

    my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="">empty_label</option>
<option value="one">One</option>
<option value="two">Two</option>
</select>
</div>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}
{
    my $field = $form->element('Select')->name('foo');
    $field->empty_first(1);
    $field->empty_first_label('empty_label');
    $field->value_range([1, 2]);

    my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="">empty_label</option>
<option value="1">1</option>
<option value="2">2</option>
</select>
</div>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}
{
    my $field = $form->element('Select')->name('foo');
    $field->empty_first(1);
    $field->empty_first_label_loc('test_label');
    $field->options([ [ 1 => 'One' ], [ 2 => 'Two' ] ]);

    my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="">My Label</option>
<option value="1">One</option>
<option value="2">Two</option>
</select>
</div>};

    is( "$field", $field_xhtml, 'stringified field' );
    
}
