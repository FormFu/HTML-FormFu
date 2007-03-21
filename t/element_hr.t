use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);

my $hr = $form->element('hr');

my $hr_xhtml = qq{<hr />};

is ( "$hr", $hr_xhtml );

