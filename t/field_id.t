use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

{    # element has explicit id
    my $form = HTML::FormFu->new;

    $form->element('text')->name('foo')->id('fid')->label('Foo');

    my $field_xhtml = qq{<span class="text label">
<label for="fid">Foo</label>
<input name="foo" type="text" id="fid" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
}

{    # auto_id
    my $form = HTML::FormFu->new->auto_id('%n');

    $form->element('text')->name('foo')->label('Foo');

    my $field_xhtml = qq{<span class="text label">
<label for="foo">Foo</label>
<input name="foo" type="text" id="foo" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
}

{    # auto_id
    my $form = HTML::FormFu->new->id('my_form');

    $form->element('text')->name('foo')->label('Foo')->auto_id('%f_%n');

    my $field_xhtml = qq{<span class="text label">
<label for="my_form_foo">Foo</label>
<input name="foo" type="text" id="my_form_foo" />
</span>};

    is( $form->get_field('foo'), $field_xhtml );
}
