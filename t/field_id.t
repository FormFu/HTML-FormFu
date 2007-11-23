use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

{    # element has explicit id
    my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

    $form->element('Text')->name('foo')->id('fid')->label('Foo');

    my $field_xhtml = qq{<span class="text label">
<label for="fid">Foo</label>
<input name="foo" type="text" id="fid" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
}

{    # auto_id
    my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );
    
    $form->auto_fieldset(1);
    $form->auto_id('%n');

    $form->element('Text')->name('foo')->label('Foo');

    my $field_xhtml = qq{<span class="text label">
<label for="foo">Foo</label>
<input name="foo" type="text" id="foo" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
    
    is( "$form", <<HTML );
<form action="" method="post">
<fieldset>
$field_xhtml
</fieldset>
</form>
HTML
}

{    # auto_id
    my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );
    
    $form->auto_fieldset(1);
    $form->id('my_form');

    $form->element('Text')->name('foo')->label('Foo')->auto_id('%f_%n');

    my $field_xhtml = qq{<span class="text label">
<label for="my_form_foo">Foo</label>
<input name="foo" type="text" id="my_form_foo" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
    
    is( "$form", <<HTML );
<form action="" id="my_form" method="post">
<fieldset>
$field_xhtml
</fieldset>
</form>
HTML
}
