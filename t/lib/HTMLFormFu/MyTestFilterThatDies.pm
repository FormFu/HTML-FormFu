package HTMLFormFu::MyTestFilterThatDies;

use strict;
use warnings;

use base 'HTML::FormFu::Filter';

sub filter { die "this shouldn't get called" }

1;
