use strict;
use warnings;
use Test::More;
use Test::Aggregate::Nested;

Test::Aggregate::Nested->new( {
        dirs => 't-aggregate',

        # verbose => 1,
    } )->run;
