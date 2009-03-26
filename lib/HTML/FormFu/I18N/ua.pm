package HTML::FormFu::I18N::ua;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Були помилки з введеними даними, дивись нижче',
    form_constraint_allornone => 'Помилка',
    form_constraint_ascii     => 'Поле має не-ASCII символ',
    form_constraint_autoset   => 'Поле має невірний вибір',
    form_constraint_bool =>
        'Поле має бути логічним значенням',
    form_constraint_callback => 'Невірне значення',
    form_constraint_datetime => 'Невірна дата',
    form_constraint_dependon =>
        "Це поле обов\x{02BC}язкове, якщо поле '[_1]' заповнене",
    form_constraint_email => 'Поле має бути email-адресою',
    form_constraint_equal =>
        "Не співпадає зі значенням '[_1]'",
    form_constraint_file      => 'Це не файл',
    form_constraint_file_mime => 'Невірний тип файлу',
    form_constraint_file_maxsize =>
        'Розмір файлу має бути не більше [_1] байт',
    form_constraint_file_minsize =>
        'Розмір файлу має бути не менше [_1] байт',
    form_constraint_file_size =>
        'Розмір файлу має бути між [_1] та [_2] байт',
    form_constraint_integer =>
        'Поле має бути цілим значенням',
    form_constraint_length =>
        'Длина має бути між [_1] та [_2] символів',
    form_constraint_minlength =>
        'Має бути не менше [_1] символів',
    form_constraint_minrange     => 'Має бути не менше [_1]',
    form_constraint_minmaxfields => 'Невірне значення',
    form_constraint_maxlength =>
        'Має бути не більше [_1] символів',
    form_constraint_maxrange => 'Має бути не більше [_1]',
    form_constraint_number =>
        'Поле має бути числовим значенням',
    form_constraint_printable =>
        'Поле має недрукований символ',
    form_constraint_range     => 'Має бути між [_1] та [_2]',
    form_constraint_recaptcha => 'Помилка reCAPTCHA',
    form_constraint_regex     => 'Невірне значення',
    form_constraint_required  => "Це поле обов\x{02BC}язкове",
    form_constraint_set       => 'Поле має невірний вибір',
    form_constraint_singlevalue =>
        'Це поле може приймати тільки одне значення',
    form_constraint_word =>
        'Поле має небуквенні символи',
    form_inflator_compounddatetime => 'Невірна дата',
    form_inflator_datetime         => 'Невірна дата',
    form_validator_callback        => 'Помилка перевірки',
    form_transformer_callback => 'Помилка преобразування',

    form_inflator_imager =>
        'Помилка відкриття файлу зображення',
    form_validator_imager_size =>
        'Завантажене зображення дуже велике',
    form_transformer_imager =>
        'Помилка обробки файлу зображення',
);

1;
