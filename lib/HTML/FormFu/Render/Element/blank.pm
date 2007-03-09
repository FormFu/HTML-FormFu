package HTML::FormFu::Render::Element::blank;

use strict;
use warnings;
use base 'HTML::FormFu::Render::Element::field';

sub label_tag {
    return "";
}

sub field_tag {
    return "";
}

1;
