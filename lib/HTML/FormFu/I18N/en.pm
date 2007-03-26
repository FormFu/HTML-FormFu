package HTML::FormFu::I18N::en;
use strict;
use warnings;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message     => 'There were errors with your submission, see below for details',
    form_default_error     => 'Invalid input',
    form_allornone_error   => 'Error',
    form_ascii_error       => 'Field contains invalid characters',
    form_autoset_error     => 'Field contains an invalid choice',
    form_bool_error        => 'Field must be a boolean value',
    form_dependon_error    => 'Error',
    form_email_error       => 'This field must contain an email address',
    form_equal_error       => 'Error',
    form_integer_error     => 'This field must be an integer',
    form_length_error      => 'Invalid input',
    form_minlength_error   => 'Must be at least [_1] characters long',
    form_maxlength_error   => 'Must not be longer than [_1] characters long',
    form_number_error      => 'This field must be a number',
    form_printable_error   => 'Field contains invalid characters',
    form_range_error       => 'Invalid input',
    form_regex_error       => 'Invalid input',
    form_required_error    => 'This field is required',
    form_set_error         => 'Field contains an invalid choice',
    form_singlevalue_error => 'This field only accepts a single value',
    form_word_error        => 'Field contains invalid characters',
);

1;
