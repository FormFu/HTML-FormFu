use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

eval { $form->element( { name => 'foo.bar' } ); };

# died

ok($@);
