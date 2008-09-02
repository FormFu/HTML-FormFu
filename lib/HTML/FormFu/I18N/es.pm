package HTML::FormFu::I18N::es;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message             => 'Los datos enviados contienen errores, mas abajo puedes ver mas detalles',
    form_constraint_allornone      => 'Error',
    form_constraint_ascii          => 'El campo contiene caracteres inválidos',
    form_constraint_autoset        => 'El campo contiene una opción inválida',
    form_constraint_bool           => 'El campo debe contener un valor booleano',
    form_constraint_callback       => 'Entrada inválida',
    form_constraint_datetime       => 'Fecha inválida',
    form_constraint_dependon       => 'Error',
    form_constraint_email          => 'Este campo debe contener una dirección de email',
    form_constraint_equal          => 'Error',
    form_constraint_file           => 'No es un fichero',
    form_constraint_file_mime      => 'Tipo de fichero inválido',
    form_constraint_file_size      => 'Tamaño del fichero inválido',
    form_constraint_integer        => 'Este campo debe contener un número entero',
    form_constraint_length         => 'Entrada inválida',
    form_constraint_minlength      => 'Debe tener al menos [_1] caracteres de largo',
    form_constraint_minmaxfields   => 'Entrada inválida',
    form_constraint_maxlength      => 'No debe tener mas de [_1] caracteres de largo',
    form_constraint_number         => 'Este campo debe contener un número',
    form_constraint_printable      => 'El campo contiene caracteres inválidos',
    form_constraint_range          => 'Entrada inválida',
    form_constraint_regex          => 'Entrada inválida',
    form_constraint_required       => 'Este campo es obligatorio',
    form_constraint_set            => 'El campo contiene una opción inválida',
    form_constraint_singlevalue    => 'Este campo acepta un solo valor',
    form_constraint_word           => 'El campo contiene caracteres inválidos',
    form_inflator_compounddatetime => 'Fecha inválida',
    form_inflator_datetime         => 'Fecha inválida',
    form_validator_callback        => 'Error en el validador',
    form_transformer_callback      => 'Error en el transformador',

    form_inflator_imager           => 'Error al abrir el fichero de la imagen',
    form_validator_imager_size     => 'La imagen subida es demasiado grande',
    form_transformer_imager        => 'Error al procesar la imagen',
);

1;
