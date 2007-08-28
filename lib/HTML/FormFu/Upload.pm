package HTML::FormFu::Upload;

use strict;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw/ form parent /;

__PACKAGE__->mk_accessors(qw/ _param /);

1;
