use strict;
package HTML::FormFu::Constants;

use warnings;


use Readonly;
use Exporter qw( import );

Readonly our $EMPTY_STR => q{};
Readonly our $SPACE     => q{ };

our @EXPORT_OK = qw(
    $EMPTY_STR
    $SPACE
);

1;
