package HTML::FormFu::I18N::no;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Noen av dine verdier var ugyldige. Se under for detaljer',
    form_constraint_allornone => 'Feil',
    form_constraint_ascii     => 'Feltet inneholder tegn som ikke er ASCII',
    form_constraint_autoset   => 'Feltet har et ugyldig alternativ',
    form_constraint_bool      => 'Du må velge 1 eller 0',
    form_constraint_callback  => 'Ugyldig svar',
    form_constraint_datetime  => 'Ugyldig dato',
    form_constraint_dependon =>
        "Dette feltet er påkrevd hvis '[_1]' er fylt ut",
    form_constraint_email     => 'Du har gitt en ugyldig epostadresse',
    form_constraint_equal     => "Stemmer ikke med verdien i '[_1]'",
    form_constraint_file      => 'Ikke en fil',
    form_constraint_file_mime => 'Ugyldig fil-type',
    form_constraint_file_maxsize =>
        'Filen kan ikke være større enn [_1] bytes',
    form_constraint_file_minsize => 'Filen må være minst [_1] bytes',
    form_constraint_file_size    => 'Filen må være mellom [_1] og [_2] bytes',
    form_constraint_integer      => 'Feltet må innehold et heltall',
    form_constraint_length       => 'Må være mellom [_1] og [_2] tegn',
    form_constraint_minlength    => 'Må være minst [_1] tegn',
    form_constraint_minrange     => 'Må være minst [_1]',
    form_constraint_minmaxfields => 'Ugyldig valg',
    form_constraint_maxlength    => 'Kan ikke være mer enn [_1] tegn',
    form_constraint_maxrange     => 'Kan ikke være mer enn [_1]',
    form_constraint_number       => 'Dette feltet må inneholde et tall',
    form_constraint_printable    => 'Feltet inneholder tegn som ikke kan vises',
    form_constraint_range        => 'Må være mellom [_1] og [_2]',
    form_constraint_recaptcha    => 'ugyldig reCAPTCHA',
    form_constraint_regex        => 'Ugyldig verdi',
    form_constraint_required     => 'Dette feltet må være utfylt',
    form_constraint_set          => 'Feltet inneholder et ugyldig valg',
    form_constraint_singlevalue  => 'Dette feltet tar bare en verdi',
    form_constraint_word => 'Feltet inneholder verdier som ikke er bokstaver',
    form_inflator_compounddatetime => 'Ugyldig dato',
    form_inflator_datetime         => 'Ugyldig dato',
    form_validator_callback        => 'Feil i validering',
    form_transformer_callback      => 'Feil under transformering',

    form_inflator_imager       => 'Kunne ikke åpne bildefilen',
    form_validator_imager_size => 'Bildet er for stort',
    form_transformer_imager    => 'Feil ved behandling av bilde',
);

1;
