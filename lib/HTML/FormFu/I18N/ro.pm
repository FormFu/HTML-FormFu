package HTML::FormFu::I18N::ro;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Formularul dumneavoastră conţine erori, vedeţi mai jos detaliile',
    form_constraint_allornone => 'Eroare',
    form_constraint_ascii     => 'Câmpul conţine caractere non-ASCII',
    form_constraint_autoset   => 'Câmpul conţine o opţiune inacceptabilă',
    form_constraint_bool     => 'Câmpul trebuie să aibă o valoare booleană',
    form_constraint_callback => 'Introducere inacceptabilă',
    form_constraint_datetime => 'Dată incorectă',
    form_constraint_dependon =>
        "Acest câmp este obligatoriu dacă câmpul '[_1]' este completat",
    form_constraint_email =>
        'Acest câmp trebuie să conţină o adresă de email',
    form_constraint_equal => "Nu are o valoare identică cu a câmpului '[_1]'",
    form_constraint_file  => 'Nu este un fişier',
    form_constraint_file_mime => 'Tip de fişier inacceptabil',
    form_constraint_file_maxsize =>
        'Mărimea fişierului nu trebuie să fie mai mare de [_1] bytes',
    form_constraint_file_minsize =>
        'Mărimea fişierului trebuie să fie de cel puţin [_1] bytes',
    form_constraint_file_size =>
        'Fişierul trebuie să aibă între [_1] şi [_2] bytes',
    form_constraint_integer =>
        'Acest câmp trebuie să conţină un număr întreg',
    form_constraint_length =>
        'Trebuie să aibă între [_1] şi [_2] caracterelong',
    form_constraint_minlength =>
        'Trebuie să aibă cel puţin [_1] caracterelong',
    form_constraint_minrange =>
        'Trebuie să aibă o valoare de cel puţin [_1]',
    form_constraint_minmaxfields => 'Introducere inacceptabilă',
    form_constraint_maxlength =>
        'Trebuie să nu aibă o lungime mai mare de [_1] caractere',
    form_constraint_maxrange =>
        'Trebuie să nu aiba o valoare mai mare de [_1]',
    form_constraint_number => 'Acest câmp trebuie să conţină un număr',
    form_constraint_printable =>
        'Câmpul conţine caractere care nu pot fi afişate',
    form_constraint_range => 'Trebuie să aibă o valoare între [_1] şi [_2]',
    form_constraint_recaptcha => 'Eroare reCAPTCHA',
    form_constraint_regex     => 'Introducere inacceptabilă',
    form_constraint_required  => 'Acest câmp este obligatoriu',
    form_constraint_set       => 'Câmpul conţine o opţiune inacceptabilă',
    form_constraint_singlevalue =>
        'Acest câmp acceptă doar o singură valoare',
    form_constraint_word =>
        'Câmpul conţine alte caractere decât litere, cifre sau "_"',
    form_inflator_compounddatetime => 'Dată inacceptabilă',
    form_inflator_datetime         => 'Dată inacceptabilă',
    form_validator_callback        => 'Eroare de validare',
    form_transformer_callback      => 'Eroare de transformare',

    form_inflator_imager       => 'Eroare la deschiderea fişierului imagine',
    form_validator_imager_size => 'Imaginea încărcată este prea mare',
    form_transformer_imager    => 'Eroare la procesarea fişierului imagine',
);

1;
