use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# force a submission
$form->indicator( sub {1} );

my $hr = $form->element('Hr');

$form->process( {} );

my $hr_xhtml = qq{<hr />};

is( "$hr", $hr_xhtml );

