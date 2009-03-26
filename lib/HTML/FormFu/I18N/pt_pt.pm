package HTML::FormFu::I18N::pt_pt;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Existem erros na submição, veja os detalhes mais abaixo',
    form_constraint_allornone => 'Erro',
    form_constraint_ascii     => 'Campo contém caracteres inválidos',
    form_constraint_autoset   => 'Campo contém uma escolha inválida',
    form_constraint_bool      => 'Campo tem de ser um valor booleano',
    form_constraint_dependon  => 'Erro',
    form_constraint_email =>
        'Este campo tem de conter um endereço de email válido',
    form_constraint_equal     => 'Erro',
    form_constraint_integer   => 'Este campo tem de conter um número inteiro',
    form_constraint_length    => 'Entrada inválida',
    form_constraint_minlength => 'Tem que conter pelo menos [_1] caracteres.',
    form_constraint_maxlength => 'Não pode conter mais de [_1] caracteres',
    form_constraint_number    => 'Este campo deverá ser um número',
    form_constraint_printable => 'Este campo contém caracteres inválidos',
    form_constraint_range     => 'Entrada inválida',
    form_constraint_regex     => 'Entrada inválida',
    form_constraint_required  => 'Este campo é obrigatório',
    form_constraint_set       => 'Campo comtém uma escolha inválida',
    form_constraint_singlevalue => 'Este campo só aceita um valor único',
    form_constraint_word        => 'Campo comtém caracteres inválidos',
    form_inflator_datetime      => 'Data inválida',

    form_inflator_imager       => 'Erro ao abrir a imagem',
    form_validator_imager_size => 'Imagem muito grande',
    form_transformer_imager    => 'Erro ao processar a imagem',
);

1;
