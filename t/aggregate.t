use strict;
use warnings;

use Test::Aggregate;

my $tester = Test::Aggregate->new({
    dirs       => 't-aggregated',
    verbose    => 1,
    #check_plan => 1,
});

$tester->run;
