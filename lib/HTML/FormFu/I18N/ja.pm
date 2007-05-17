package HTML::FormFu::I18N::ja;
use strict;
use warnings;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message     => 'フォーム内容が不正です',
    form_default_error     => '不正な値です',
    form_allornone_error   => 'Error',
    form_ascii_error       => '不正な文字が使用されています',
    form_autoset_error     => 'Field contains invalid choice',
    form_bool_error        => 'Field must be a boolean value',
    form_dependon_error    => 'Error',
    form_email_error       => 'メールアドレスの書式が不正です',
    form_equal_error       => '値が一致しません',
    form_integer_error     => '整数を指定してください',
    form_length_error      => '不正な値です',
    form_minlength_error   => '最低[_1]文字の入力が必要です',
    form_maxlength_error   => '最大[_1]文字まで入力可能です',
    form_number_error      => '数値を指定してください',
    form_printable_error   => '不正な文字が使用されています',
    form_range_error       => '不正な値が使用されています',
    form_regex_error       => '不正な値が使用されています',
    form_required_error    => '必須項目',
    form_set_error         => '不正な項目が選択されています',
    form_singlevalue_error => '複数の値が設定されています',
    form_word_error        => '不正な文字が仕様されています',
);

1;
