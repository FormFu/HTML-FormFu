use strict;
use warnings;

use Test::More tests => 1;

use lib 't/lib';
use HTML::FormFu;

my $form = HTML::FormFu->new( {
    localize_class => 'HTMLFormFu::I18N',
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
} );

$form->element('Text')->name('foo')->label_loc('test_label')
    ->comment_loc('test_comment')->default_loc('test_default_value');

my $xhtml = qq{<span class="text comment label">
<label>My Label</label>
<input name="foo" type="text" value="My Default" />
<span class="comment">
My Comment
</span>
</span>};

is( $form->get_field('foo'), $xhtml );
