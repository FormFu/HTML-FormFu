use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $end_form = qq{</form>};

is( $form->end_form, $end_form );
