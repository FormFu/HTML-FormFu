package HTML::FormFu::Element::Blank;

use strict;
use base 'HTML::FormFu::Element::_Input';

use HTML::FormFu::Constants qw( $EMPTY_STR );

sub label_tag {
    return $EMPTY_STR;
}

sub field_tag {
    return $EMPTY_STR;
}

sub render {
    return $EMPTY_STR;
}

sub render_data_non_recursive {
    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Blank - blank element

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
