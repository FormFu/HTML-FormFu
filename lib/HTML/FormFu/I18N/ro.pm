package HTML::FormFu::I18N::ro;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message             => 'Trimiterea dumneavoastră conţine erori, vedeţi mai jos detaliile',
    form_constraint_allornone      => 'Eroare',
    form_constraint_ascii          => 'Câmpul conţine caractere neacceptate',
    form_constraint_autoset        => 'Câmpul conţine o opţiune neacceptată',
    form_constraint_bool           => 'Câmpul trebuie să fie o valoare booleană',
    form_constraint_callback       => 'Introducere neacceptată',
    form_constraint_datetime       => 'Dată neacceptată',
    form_constraint_dependon       => 'Eroare',
    form_constraint_email          => 'Acest câmp trebuie să conţină o adresă de email',
    form_constraint_equal          => 'Eroare',
    form_constraint_file           => 'Nu este un fişier',
    form_constraint_file_mime      => 'Tip de fişier neacceptat',
    form_constraint_file_size      => 'Mărime a fişierului neacceptată',
    form_constraint_integer        => 'Acest câmp trebuie să fie un număr întreg',
    form_constraint_length         => 'Introducere neacceptată',
    form_constraint_minlength      => 'Trebuie să aibă cel puţin [_1] caractere',
    form_constraint_minmaxfields   => 'Introducere neacceptată',
    form_constraint_maxlength      => 'Trebuie să nu aibă mai mult de [_1] caractere',
    form_constraint_number         => 'Acest câmp trebuie să fie un număr',
    form_constraint_printable      => 'Câmpul conţine caractere neacceptate',
    form_constraint_range          => 'Introducere neacceptată',
    form_constraint_recaptcha      => 'Eroare reCAPTCHA',
    form_constraint_regex          => 'Introducere neacceptată',
    form_constraint_required       => 'Acest câmp este obligatoriu',
    form_constraint_set            => 'Câmpul conţine o opţiune neacceptată',
    form_constraint_singlevalue    => 'Acest câmp acceptă doar o singură valoare',
    form_constraint_word           => 'Câmpul conţine caractere neacceptate',
    form_inflator_compounddatetime => 'Dată neacceptată',
    form_inflator_datetime         => 'Dată neacceptată',
    form_validator_callback        => 'Eroare de validare',
    form_transformer_callback      => 'Eroare de transformare',

    form_inflator_imager           => 'Eroare la deschiderea fişierului imagine',
    form_validator_imager_size     => 'Imagine încărcată prea mare',
    form_transformer_imager        => 'Eroare la procesarea fişierului imagine',
);

1;
