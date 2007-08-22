package HTML::FormFu::I18N::de;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_constraint_allornone   => 'Ungültig',
    form_constraint_ascii       => 'Feld enthält ungültige Zeichen',
    form_constraint_autoset     => 'Feld enthält eine ungültige Auswahl',
    form_constraint_bool        => 'Feld muss einen Logikwert enthalten',
    form_constraint_dependon    => 'Ungültig',
    form_constraint_email       => 'Feld muss eine Email Adresse enthalten',
    form_constraint_equal       => 'Ungültig',
    form_constraint_integer     => 'Feld muss eine Ganzzahl enthalten',
    form_constraint_length      => 'Ungültige Eingabe',
    form_constraint_number      => 'Feld muss eine Zahl enthalten',
    form_constraint_printable   => 'Feld enthält ungültige Zeichen',
    form_constraint_range       => 'Ungültige Eingabe',
    form_constraint_regex       => 'Ungültige Eingabe',
    form_constraint_required    => 'Feld muss ausgefüllt sein',
    form_constraint_set         => 'Feld enthält eine ungültige Auswahl',
    form_constraint_singlevalue => 'Feld darf nur einen einzigen Wert enhalten',
    form_constraint_word        => 'Feld enthält ungültige Zeichen',
);

1;
