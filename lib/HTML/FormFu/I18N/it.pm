use strict;

package HTML::FormFu::I18N::it;
# ABSTRACT: Italian

use utf8;

use Moose;
extends 'HTML::FormFu::I18N';

our %Lexicon = (
    form_error_message =>
        q(Ci sono stati alcuni errori nell'invio del modulo, vedi oltre per i dettagli),
    form_constraint_allornone => 'Errore',
    form_constraint_ascii     => 'Il campo contiene caratteri non ASCII',
    form_constraint_autoset   => 'Il campo contiene una scelta non valida',
    form_constraint_bool =>
        'Il campo deve contenere un valore booleano (vero o falso)',
    form_constraint_callback    => 'Dato non valido',
    form_constraint_datetime    => 'Data non valida',
    form_constraint_dbic_unique => 'Il valore è già nel database',
    form_constraint_dependon =>
        q(Questo campo è obbligatorio se '[_1]' ha un valore),
    form_constraint_email     => 'Il campo deve contenere un indirizzo email',
    form_constraint_equal     => q(Non coincide con '[_1]'),
    form_constraint_file      => 'Non hai indicato un file',
    form_constraint_file_mime => 'Tipo di file non valido',
    form_constraint_file_maxsize =>
        'La dimensione del file non può superare [_1] byte',
    form_constraint_file_minsize =>
        'La dimensione del file non può essere inferioree a [_1] byte',
    form_constraint_file_size =>
        'Dimensione file deve essere tra [_1] e [_2] byte',
    form_constraint_integer => 'Il campo deve contenere un numero intero',
    form_constraint_length =>
        q(La lunghezza deve essere tra [_1] e [_2] caratteri),
    form_constraint_minlength    => 'Deve essere lungo almeno [_1] caratteri',
    form_constraint_minrange     => q(Deve essere almeno [_1]),
    form_constraint_minmaxfields => 'Dato non valido',
    form_constraint_maxlength => 'Deve essere lungo al massimo [_1] caratteri',
    form_constraint_maxrange  => q(Non devono essercene più di [_1]),
    form_constraint_number    => 'Il campo deve contenere un numero',
    form_constraint_printable => 'Il campo contiene caratteri non validi',
    form_constraint_range     => q(Deve essere tra [_1] e [_2]),
    form_constraint_recaptcha => 'Errore di reCAPTCHA',
    form_constraint_regex     => 'Dato non valido',
    form_constraint_repeatable_any =>
        q(È obbligatorio almeno uno campo '[_1]'),
    form_constraint_required       => 'Questo campo è obbligatorio',
    form_constraint_set            => 'Il campo contiene una scelta non valida',
    form_constraint_singlevalue    => 'Il campo accetta solo valori singoli',
    form_constraint_word           => 'Il campo contiene caratteri non validi',
    form_inflator_compounddatetime => 'Data non valida',
    form_inflator_datetime         => 'Data non valida',
    form_validator_callback        => 'Errore nel Validator',
    form_transformer_callback      => 'Errore nel Transformer',

    form_inflator_imager       => q(Impossibile aprire il file dell'immagine),
    form_validator_imager_size => q(L'immagine inviata è troppo grande),
    form_transformer_imager => q(Impossibile elaborare il file dell 'immagine),
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
