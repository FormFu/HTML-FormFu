package HTML::FormFu::Upload;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw/ form /;

__PACKAGE__->mk_accessors(qw/ _param parent /);

1;
