use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Hidden')->name('foo');
$form->element('Hidden')->name('bar');

my $xhtml
    = qq{<input name="foo" type="hidden" /><input name="bar" type="hidden" />};

is( $form->hidden_fields, $xhtml );
