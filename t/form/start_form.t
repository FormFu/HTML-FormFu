use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $start_form = qq{<form action="" method="post">};

is( $form->start_form, $start_form );
