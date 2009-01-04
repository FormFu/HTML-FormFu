use strict;
use warnings;

use Test::More tests => 1;
use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::MyObject;

my $object = HTMLFormFu::MyObject->new( 'bar' );

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element({
    type     => 'Select',
    name     => 'foo',
    values   => [qw/ foo bar baz /],
    default  => $object,
    deflator => '+HTMLFormFu::MyDeflator',
});

$form->process;

my $field_xhtml = qq{<div class="select">
<select name="foo">
<option value="foo">Foo</option>
<option value="bar" selected="selected">Bar</option>
<option value="baz">Baz</option>
</select>
</div>};

is( "$field", $field_xhtml );
