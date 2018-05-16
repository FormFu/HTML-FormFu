use strict;

package HTML::FormFu::I18N::hu;
# ABSTRACT: Ungarian

use Moose;
use utf8;

extends 'HTML::FormFu::I18N';

our %Lexicon;

%Lexicon = (
    form_error_message        => 'Az elküldött adatok hibásak',
    form_constraint_allornone => 'Hiba',
    form_constraint_ascii     => 'Nem ASCII karakter',
    form_constraint_autoset   => 'Érvénytelen választás',
    form_constraint_bool      => 'Nem logikai érték',
    form_constraint_callback  => 'Érvénytelen adat',
    form_constraint_datetime  => 'Érvénytelen dátum',
    form_constraint_dependon =>
        'A(z) \'[_1]\' kitöltése miatt hiányzó adat',
    form_constraint_dbic_unique  => 'Már létező adat',
    form_constraint_email        => 'Nem email cím',
    form_constraint_equal        => 'Nem \'[_1]\'',
    form_constraint_file         => 'Nem fájl',
    form_constraint_file_mime    => 'Érvénytelen MIME típus',
    form_constraint_file_maxsize => 'Az állomány nagyobb [_1] bájtnál',
    form_constraint_file_minsize => 'Az állomány kisebb [_1] bájtnál',
    form_constraint_file_size =>
        'Az állomány nincs [_1] és [_2] bájt között',
    form_constraint_integer        => 'Nem egész szám',
    form_constraint_length         => 'Nincs [_1] és [_2] karakter között',
    form_constraint_minlength      => 'Rövidebb, mint [_1] karakter',
    form_constraint_minrange       => 'Kisebb, mint [_1]',
    form_constraint_minmaxfields   => 'Érvénytelen adat',
    form_constraint_maxlength      => 'Hosszabb, mint [_1] karakter',
    form_constraint_maxrange       => 'Nagyobb, mint [_1]',
    form_constraint_number         => 'Nem szám',
    form_constraint_printable      => 'Nem nyomtatható karakter',
    form_constraint_range          => 'Nincs [_1] és [_2] között',
    form_constraint_recaptcha      => 'reCAPTCHA hiba',
    form_constraint_regex          => 'Érvénytelen adat',
    form_constraint_required       => 'Hiányzó adat',
    form_constraint_set            => 'Érvénytelen választás',
    form_constraint_singlevalue    => 'Egynél többb válasz',
    form_constraint_word           => 'Érvénytelen karakter',
    form_inflator_compounddatetime => 'Érvénytelen dátum',
    form_inflator_datetime         => 'Érvénytelen dátum',
    form_validator_callback        => 'Ellenőrzési hiba',
    form_transformer_callback      => 'Feldolgozási hiba',
    form_inflator_imager           => 'A kép nem nyitható meg',
    form_validator_imager_size     => 'A kép túl nagy',
    form_transformer_imager        => 'A kép nem dolgozható fel',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
