package HTML::FormFu::Exception;

use strict;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw/ form /;

__PACKAGE__->mk_accessors(qw/ parent /);

1;
