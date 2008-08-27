package HTML::FormFu::I18N::pt_br;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Existem error no seu envio, veja os detalhes abaixo',
    form_constraint_allornone    => 'Erro',
    form_constraint_ascii        => 'Campo contém caracteres inválidos',
    form_constraint_autoset      => 'Campo contém uma escolha inválida',
    form_constraint_bool         => 'Campo deve ter um valor verdadeiro ou falso',
    form_constraint_callback     => 'Entrada inválida',
    form_constraint_datetime     => 'Data inválida',
    form_constraint_dependon     => 'Erro',
    form_constraint_email        => 'Este campo deve conter um endereço de email',
    form_constraint_equal        => 'Erro',
    form_constraint_file         => 'Não é um arquivo',
    form_constraint_file_mime    => 'Tipo de arquivo inválido',
    form_constraint_file_size    => 'Tamanho de arquivo inválido',
    form_constraint_integer      => 'Este campo deverá ser um número inteiro',
    form_constraint_length       => 'Entrada inválida',
    form_constraint_minlength    => 'Deve ter pelo menos [_1] caracteres',
    form_constraint_minmaxfields => 'Entrada inválida',
    form_constraint_maxlength => 'Não pode ser maior que [_1] caracteres',
    form_constraint_number    => 'Este campo tem que ser um número',
    form_constraint_printable => 'Este campo contém caracteres inválidos',
    form_constraint_range     => 'Entrada inválida',
    form_constraint_regex     => 'Entrada inválida',
    form_constraint_required  => 'Este campo é obrigatório',
    form_constraint_set       => 'Campo contém uma escolha inválida',
    form_constraint_singlevalue    => 'Este campo só aceita um valor único',
    form_constraint_word           => 'Campo contém caracteres inválidos',
    form_inflator_compounddatetime => 'Data inválida',
    form_inflator_datetime         => 'Data inválida',
    form_validator_callback        => 'Erro de validação',
    form_transformer_callback      => 'Erro na transformação',

    form_inflator_imager       => 'Erro ao abrir a imagem',
    form_validator_imager_size => 'Imagem muito grande',
    form_transformer_imager    => 'Erro ao processar a imagem',
);

1;
