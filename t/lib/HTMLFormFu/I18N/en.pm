package HTMLFormFu::I18N::en;
use strict;
use warnings;

use base qw( HTMLFormFu::I18N );

our %Lexicon = (
    test_label         => 'My Label',
    test_comment       => 'My Comment',
    test_default_value => 'My Default',
    test_two_args      => 'My [_1] [_2] args',
    label_foo          => 'Foo label',
    label_form_bar     => 'Bar label',
    form_validator_htmlformfu_myvalidator => 'myvalidator error!'
);

1;
