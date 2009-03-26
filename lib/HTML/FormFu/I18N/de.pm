package HTML::FormFu::I18N::de;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Ihre Eingabe enhält Fehler, Hinweise sind unten aufgeführt',
    form_constraint_allornone => 'Ungültig',
    form_constraint_ascii     => 'Feld enthält ungültige Zeichen',
    form_constraint_autoset   => 'Feld enthält eine ungültige Auswahl',
    form_constraint_bool      => 'Feld muss einen Logikwert enthalten',
    form_constraint_callback  => 'Ungültiger Eintrag',
    form_constraint_datetime  => 'Ungültiges Datum',
    form_constraint_dependon =>
        "Dieses Feld ist vorgeschrieben wenn Feld '[_1]' ausgefüllt ist",
    form_constraint_email     => 'Feld muss eine Email Adresse enthalten',
    form_constraint_equal     => "Entspricht nicht mit Wert '[_1]' überein",
    form_constraint_file      => 'Ist nicht eine Datei',
    form_constraint_file_mime => 'Ungültiger Datei Typ',
    form_constraint_file_maxsize =>
        'Datei kann nicht grösser als [_1] Bytes sein',
    form_constraint_file_minsize =>
        'Datei muss mindestens [_1] Bytes gross sein',
    form_constraint_file_size =>
        'Dateigrösse muss zwischen [_1] und [_2] Bytes sein',
    form_constraint_integer => 'Feld muss eine Ganzzahl enthalten',
    form_constraint_length => 'Länge muss zwischen [_1] und [_2] Zeichen sein',
    form_constraint_minlength    => 'Muss mindestens [_1] Zeichen lang sein',
    form_constraint_minrange     => 'Muss mindenstens [_1] sein',
    form_constraint_minmaxfields => 'Ungültiger Eintrag',
    form_constraint_maxlength    => 'Muss nicht länger als [_1] Zeichen sein',
    form_constraint_maxrange     => 'Muss nicht mehr als [_1] sein',
    form_constraint_number       => 'Feld muss eine Zahl enthalten',
    form_constraint_printable    => 'Feld enthält nicht druckbare Zeichen',
    form_constraint_range        => 'Muss zwischen [_1] und [_2] sein',
    form_constraint_recaptcha    => 'reCAPTCHA Fehler',
    form_constraint_regex        => 'Ungültiger Eintrag',
    form_constraint_required     => 'Feld muss ausgefüllt sein',
    form_constraint_set          => 'Feld enthält eine ungültige Auswahl',
    form_constraint_singlevalue => 'Feld darf nur einen einzigen Wert enhalten',
    form_constraint_word        => 'Feld enthält ungültige Zeichen',
    form_inflator_compounddatetime => 'Ungültiges Datum',
    form_inflator_datetime         => 'Ungültiges Datum',
    form_validator_callback        => 'Validierungsfehler',
    form_transformer_callback      => 'Umwandlungsfehler',

    form_inflator_imager       => 'Fehler beim öffnen der Bilddatei',
    form_validator_imager_size => 'Hochgeladetes Bild zu gross',
    form_transformer_imager    => 'Fehler bei der Berabeitung der Bilddatei',
);

1;
