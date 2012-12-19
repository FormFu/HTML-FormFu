package HTML::FormFu::I18N::cs;
use utf8;

use Moose;
extends 'HTML::FormFu::I18N';

our %Lexicon = (
    form_error_message =>
        'Chyba při odesílání, podrobnosti jsou níže',
    form_constraint_allornone => 'Chyba',
    form_constraint_ascii     => 'Pole obsahuje jiné než ASCII znaky',
    form_constraint_autoset   => 'Pole obsahuje neplatnou volbu',
    form_constraint_bool      => 'Pole musí mít logickou hodnotu',
    form_constraint_callback  => 'Neplatný vstup',
    form_constraint_datetime  => 'Neplatné datum',
    form_constraint_dependon =>
        "Toto pole je povinné pokud je vyplněno pole '[_1]'",
    form_constraint_email        => 'Pole musí obsahovat e-mailovou adresu',
    form_constraint_equal        => "Neshoduje se s hodnotou '[_1]'",
    form_constraint_file         => 'Není soubor',
    form_constraint_file_mime    => 'Neplatný typ souboru',
    form_constraint_file_maxsize => 'Soubor nesmí být větší než [_1] bajtů',
    form_constraint_file_minsize => 'Soubor musí být velký alespoň [_1] bajtů',
    form_constraint_file_size =>
        'Soubor musí být velký mezi [_1] a [_2] bajty',
    form_constraint_integer => 'Pole musí obsahovat celočíselnou hodnotu',
    form_constraint_length  => 'Pole musí být dlouhé mezi [_1] a [_2] znaky',
    form_constraint_minlength    => 'Pole musí být dlouhé alespoň [_1] znaků',
    form_constraint_minrange     => 'Musí být alespoň [_1]',
    form_constraint_minmaxfields => 'Neplatný vstup',
    form_constraint_maxlength => 'Nesmí bý delsí než [_1] znaků',
    form_constraint_maxrange  => 'Nesmí být více než [_1]',
    form_constraint_number    => 'Pole musí obsahovat číslo',
    form_constraint_printable => 'Pole obsahuje netisknutelné znaky',
    form_constraint_range     => 'Musí být mezi [_1] a [_2]',
    form_constraint_recaptcha => 'Chyba reCAPTCHA',
    form_constraint_regex     => 'Neplatný vstup',
    form_constraint_required  => 'Pole je povinné',
    form_constraint_set       => 'Pole obsahuje neplatnou volbu',
    form_constraint_singlevalue    => 'Pole přijímá jen jednu hodnotu',
    form_constraint_word           => 'Pole obsahuje jiné znaky než slova',
    form_inflator_compounddatetime => 'Neplatné datum',
    form_inflator_datetime         => 'Neplatné datum',
    form_validator_callback        => 'Chyba ověření',
    form_transformer_callback      => 'Chyba převodu',

    form_inflator_imager       => 'Chyba při otevírání obrázku',
    form_validator_imager_size => 'Nahraný obrázek je příliš velký',
    form_transformer_imager    => 'Chyba při zpracování obrázku',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
