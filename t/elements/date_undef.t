use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->populate({elements => [{type => "Date", name => "foo", default => '30-08-2009'}]});

$form->process;

like($form->render, qr/value="2009" selected="selected"/);

$form->get_field('foo')->default(undef);

like($form->render, qr/value="2009">/);