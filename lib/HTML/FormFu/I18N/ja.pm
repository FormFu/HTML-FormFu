package HTML::FormFu::I18N::ja;
use strict;
use warnings;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message        => 'フォーム内容が不正です',
    form_constraint_allornone => 'Error',
    form_constraint_ascii     => '不正な文字が使用されています',
    form_constraint_autoset   => 'Field contains invalid choice',
    form_constraint_bool      => 'Field must be a boolean value',
    form_constraint_dependon  => 'Error',
    form_constraint_email   => 'メールアドレスの書式が不正です',
    form_constraint_equal   => '値が一致しません',
    form_constraint_integer => '整数を指定してください',
    form_constraint_length  => '不正な値です',
    form_constraint_minlength   => '最低[_1]文字の入力が必要です',
    form_constraint_maxlength   => '最大[_1]文字まで入力可能です',
    form_constraint_number      => '数値を指定してください',
    form_constraint_printable   => '不正な文字が使用されています',
    form_constraint_range       => '不正な値が使用されています',
    form_constraint_regex       => '不正な値が使用されています',
    form_constraint_required    => '必須項目',
    form_constraint_set         => '不正な項目が選択されています',
    form_constraint_singlevalue => '複数の値が設定されています',
    form_constraint_word        => '不正な文字が仕様されています',
);

1;
