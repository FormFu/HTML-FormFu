use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Text')->name('foo&')->label('<foo')->comment('foo>')
    ->default("'foo")->attrs( { class => "foo'" } )
    ->add_attrs( { class => 'bar"' } )->container_attrs( { class => 'foo"' } );

$form->element('Text')->name('foo&')->label_xml('<foo')->comment_xml('foo>')
    ->default_xml("'foo")->attrs_xml( { class => "foo'" } )
    ->add_attrs_xml( { class => 'bar"' } )
    ->container_attrs_xml( { class => 'foo"' } );

my $form_xhtml = <<EOF;
<form action="" method="post">
<div class="foo&#34;">
<label>&lt;foo</label>
<input name="foo&#38;" type="text" value="&#39;foo" class="foo&#39; bar&#34;" />
<span>
foo&gt;
</span>
</div>
<div class="foo"">
<label><foo</label>
<input name="foo&#38;" type="text" value="'foo" class="foo' bar"" />
<span>
foo>
</span>
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

