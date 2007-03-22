package HTML::FormFu::I18N::de;
use strict;
use warnings;

use base qw( HTML::FormFu::I18N );

use utf8;

our %Lexicon = (
    form_default_error     => 'Ungültige Eingabe',
    form_allornone_error   => 'Ungültig',
    form_ascii_error       => 'Feld enthält ungültige Zeichen',
    form_autoset_error     => 'Feld enthält eine ungültige Auswahl',
    form_bool_error        => 'Feld muss einen Logikwert enthalten',
    form_dependon_error    => 'Ungültig',
    form_email_error       => 'Feld muss eine Email Adresse enthalten',
    form_equal_error       => 'Ungültig',
    form_integer_error     => 'Feld muss eine Ganzzahl enthalten',
    form_length_error      => 'Ungültige Eingabe',
    form_number_error      => 'Feld muss eine Zahl enthalten',
    form_printable_error   => 'Feld enthält ungültige Zeichen',
    form_range_error       => 'Ungültige Eingabe',
    form_regex_error       => 'Ungültige Eingabe',
    form_required_error    => 'Feld muss ausgefüllt sein',
    form_set_error         => 'Feld enthält eine ungültige Auswahl',
    form_singlevalue_error => 'Feld darf nur einen einzigen Wert enhalten',
    form_word_error        => 'Feld enthält ungültige Zeichen',
);

1;
