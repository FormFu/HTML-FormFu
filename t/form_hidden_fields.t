use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('hidden')->name('foo');
$form->element('hidden')->name('bar');

my $xhtml
    = qq{<input name="foo" type="hidden" /><input name="bar" type="hidden" />};

is( $form->hidden_fields, $xhtml );
