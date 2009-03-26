package HTML::FormFu::I18N::ru;
use strict;
use utf8;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Были ошибки с введенными данными, см. ниже',
    form_constraint_allornone => 'Ошибка',
    form_constraint_ascii =>
        'Поле содержит не-ASCII символ',
    form_constraint_autoset =>
        'Поле содержит неверный выбор',
    form_constraint_bool =>
        'Поле должно быть логическим значением',
    form_constraint_callback => 'Неверное значение',
    form_constraint_datetime => 'Неверная дата',
    form_constraint_dependon =>
        "Это поле обязательное, если поле '[_1]' заполнено",
    form_constraint_email =>
        'Поле должно содержать email-адрес',
    form_constraint_equal =>
        "Не совпадает со значением '[_1]'",
    form_constraint_file      => 'Это не файл',
    form_constraint_file_mime => 'Неверный тип файла',
    form_constraint_file_maxsize =>
        'Размер файла должен быть не более [_1] байт',
    form_constraint_file_minsize =>
        'Размер файла должен быть не менее [_1] байт',
    form_constraint_file_size =>
        'Размер файла должен быть между [_1] и [_2] байт',
    form_constraint_integer =>
        'Поле должно быть целым значением',
    form_constraint_length =>
        'Длина должна быть между [_1] и [_2] символов',
    form_constraint_minlength =>
        'Должно быть не менее [_1] символов',
    form_constraint_minrange => 'Должно быть не менее [_1]',
    form_constraint_minmaxfields => 'Неверное значение',
    form_constraint_maxlength =>
        'Должно быть не более [_1] символов',
    form_constraint_maxrange => 'Должно быть не более [_1]',
    form_constraint_number =>
        'Поле должно быть числовым значением',
    form_constraint_printable =>
        'Поле содержит непечатаемый символ',
    form_constraint_range => 'Должно быть между [_1] и [_2]',
    form_constraint_recaptcha => 'Ошибка reCAPTCHA',
    form_constraint_regex     => 'Неверное значение',
    form_constraint_required  => 'Это поле обязательное',
    form_constraint_set =>
        'Поле содержит неверный выбор',
    form_constraint_singlevalue =>
        'Это поле может принимать только одно значение',
    form_constraint_word =>
        'Поле содержит небуквенные символы',
    form_inflator_compounddatetime => 'Неверная дата',
    form_inflator_datetime         => 'Неверная дата',
    form_validator_callback        => 'Ошибка проверки',
    form_transformer_callback => 'Ошибка преобразования',

    form_inflator_imager =>
        'Ошибка открытия файла изображения',
    form_validator_imager_size =>
        'Загружаемое изображение слишком велико',
    form_transformer_imager =>
        'Ошибка обработки файла изображения',
);

1;
