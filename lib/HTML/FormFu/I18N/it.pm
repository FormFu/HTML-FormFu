package HTML::FormFu::I18N::it;
use strict;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Ci sono stati alcuni errori nell\'invio del modulo, vedi oltre per i dettagli',
    form_constraint_allornone => 'Errore',
    form_constraint_ascii     => 'Il campo contiene caratteri non validi',
    form_constraint_autoset   => 'Il campo contiene una scelta non valida',
    form_constraint_bool =>
        'Il campo deve contenere un valore booleano (vero o falso)',
    form_constraint_callback  => 'Dato non valido',
    form_constraint_datetime  => 'Data non valida',
    form_constraint_dependon  => 'Errore',
    form_constraint_email     => 'Il campo deve contenere un indirizzo email',
    form_constraint_equal     => 'Errore',
    form_constraint_file      => 'Non hai indicato un file',
    form_constraint_file_mime => 'Tipo di file non valido',
    form_constraint_file_size => 'Dimensione file non valida',
    form_constraint_integer   => 'Il campo deve contenere un numero intero',
    form_constraint_length    => 'Dato non valido',
    form_constraint_minlength => 'Deve essere lungo almeno [_1] caratteri',
    form_constraint_minmaxfields => 'Dato non valido',
    form_constraint_maxlength => 'Deve essere lungo al massimo [_1] caratteri',
    form_constraint_number    => 'Il campo deve contenere un numero',
    form_constraint_printable => 'Il campo contiene caratteri non validi',
    form_constraint_range     => 'Dato non valido',
    form_constraint_regex     => 'Dato non valido',
    form_constraint_required  => 'Questo campo è obbligatorio',
    form_constraint_set       => 'Il campo contiene una scelta non valida',
    form_constraint_singlevalue    => 'Il campo accetta solo valori singoli',
    form_constraint_word           => 'Il campo contiene caratteri non validi',
    form_inflator_compounddatetime => 'Data non valida',
    form_inflator_datetime         => 'Data non valida',
    form_validator_callback        => 'Errore nel Validator',
    form_transformer_callback      => 'Errore nel Transformer',

    form_inflator_imager       => 'Impossibile aprire il file dell\'immagine',
    form_validator_imager_size => 'L\'immagine inviata è troppo grande',
    form_transformer_imager => 'Impossibile elaborare il file dell\'immagine',
);

1;
