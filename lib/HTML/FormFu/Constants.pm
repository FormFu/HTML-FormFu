use strict;

package HTML::FormFu::Constants;
# ABSTRACT: FormFU constants EMPTY_STR and SPACE

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
