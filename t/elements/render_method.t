use strict;
use warnings;

use Test::More;

eval { require Template; };

if ($@) {
    plan skip_all => 'Template.pm required';
    die $@;
}
else {
    plan tests => 1;
}

use HTML::FormFu;

# ensure our form is using 'string'
delete $ENV{HTML_FORMFU_RENDER_METHOD};

# tt only needs to find our custom template
my $form
    = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 't/templates' } } );

$form->element('Text')->name('foo')->render_method('tt');
$form->element('Text')->name('bar');

is( "$form", <<HTML );
<form action="" method="post">
<TEXT name="foo" />
<div>
<input name="bar" type="text" />
</div>
</form>
HTML

