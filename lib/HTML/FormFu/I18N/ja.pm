package HTML::FormFu::I18N::ja;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message        => 'フォーム内容が不正です',
    form_constraint_allornone => 'Error',
    form_constraint_ascii =>
        'ASCII範囲外の不正な文字が使用されています',
    form_constraint_autoset  => '不正な項目が選択されています',
    form_constraint_bool     => '値は論理値である必要があります',
    form_constraint_callback => '不正な入力です',
    form_constraint_datetime => '不正な日時です',
    form_constraint_dependon =>
        "項目'[_1]' が入力されている場合は、この項目も必須です",
    form_constraint_email => 'メールアドレスの書式が不正です',
    form_constraint_equal => "'[_1]'と値が一致しません",
    form_constraint_file  => '値はファイルではありません',
    form_constraint_file_mime =>
        '不正な種別のファイルが指定されています',
    form_constraint_file_maxsize =>
        '使用できるファイルの最大容量は[_1] バイトです',
    form_constraint_file_minsize =>
        'ファイルの最小容量は[_1] バイト以上です',
    form_constraint_file_size =>
        'ファイル容量は[_1] から [_2] バイトの間である必要があります',
    form_constraint_integer => '整数を指定してください',
    form_constraint_length =>
        '[_1]文字から[_2]文字の長さである必要があります',
    form_constraint_minlength    => '最低[_1]文字の入力が必要です',
    form_constraint_maxlength    => '最大[_1]文字まで入力可能です',
    form_constraint_minrange     => '最低値は[_1]です',
    form_constraint_minmaxfields => '不正な入力です',
    form_constraint_number       => '数値を指定してください',
    form_constraint_printable   => '不正な文字が使用されています',
    form_constraint_range       => '不正な値が使用されています',
    form_constraint_recaptcha   => 'reCAPTCHA エラーです',
    form_constraint_regex       => '不正な値が使用されています',
    form_constraint_required    => '必須項目',
    form_constraint_set         => '不正な項目が選択されています',
    form_constraint_singlevalue => '複数の値が設定されています',
    form_constraint_word        => '不正な文字が仕様されています',
    form_inflator_compounddatetime => '不正な日時です',
    form_inflator_datetime         => '不正な日時です',
    form_validator_callback        => '不正な入力です',
    form_transformer_callback      => 'データ変換に失敗しました',
    form_inflator_imager =>
        '画像データの処理に問題がありました',
    form_validator_imager_size =>
        '画像データの容量が大きすぎます',
    form_transformer_imager =>
        '画像データの処理に問題がありました',
);

1;
