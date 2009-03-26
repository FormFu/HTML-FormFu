package HTML::FormFu::I18N::da;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Der var fejl i de data du sendte, se detaljer nedenfor',
    form_constraint_allornone    => 'Fejl',
    form_constraint_ascii        => 'Felt indeholder ugyldige tegn',
    form_constraint_autoset      => 'Felt indeholder et ugyldigt valg',
    form_constraint_bool         => 'Felt skal være sandt/falsk',
    form_constraint_callback     => 'Ugyldige inddata',
    form_constraint_datetime     => 'Ugyldig dato',
    form_constraint_dependon     => 'Fejl',
    form_constraint_email        => 'Dette felt skal indeholde en emailadresse',
    form_constraint_equal        => 'Fejl',
    form_constraint_file         => 'Ikke en fil',
    form_constraint_file_mime    => 'Ugyldig filtype',
    form_constraint_file_size    => 'Ugyldig filstørrelse',
    form_constraint_integer      => 'Dette felt skal indeholde et heltal',
    form_constraint_length       => 'Ugyldige inddata',
    form_constraint_minlength    => 'Skal være mindst [_1] tegn lang',
    form_constraint_minmaxfields => 'Ugyldige inddata',
    form_constraint_maxlength    => 'Må ikke være længere end [_1] tegn',
    form_constraint_number       => 'Dette felt skal indeholde et tal',
    form_constraint_printable    => 'Felt indeholder ugyldige tegn',
    form_constraint_range        => 'Ugyldige inddata',
    form_constraint_regex        => 'Ugyldige inddata',
    form_constraint_required     => 'Dette felt er obligatorisk',
    form_constraint_set          => 'Felt indeholder et ugyldigt valg',
    form_constraint_singlevalue  => 'Dette felt godtager kun én værdi',
    form_constraint_word         => 'Felt indeholder ugyldige tegn',
    form_inflator_compounddatetime => 'Ugyldig dato',
    form_inflator_datetime         => 'Ugyldig dato',
    form_validator_callback        => 'Valideringsfejl',
    form_transformer_callback      => 'Transformeringsfejl',

    form_inflator_imager       => 'Fejl ved åbning af billedfil',
    form_validator_imager_size => 'Billedupload for stor',
    form_transformer_imager    => 'Fejl ved behandling af billedfil',
);

1;
