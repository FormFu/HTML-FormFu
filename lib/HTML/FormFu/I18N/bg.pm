package HTML::FormFu::I18N::bg;

use utf8;

use strict;
# VERSION

use Moose;
extends 'HTML::FormFu::I18N';

our %Lexicon = (
    form_error_message =>
        'Грешно въведени данни, вижте по-долу за детайли',
    form_constraint_allornone => 'Грешка',
    form_constraint_ascii =>
        'Полето съдържа не-ASCII символи',
    form_constraint_autoset =>
        'Полето съдържа неправилен избор',
    form_constraint_bool =>
        'Полето трябва да е с логическа стойност',
    form_constraint_callback => 'Невалидна стойност',
    form_constraint_datetime => 'Грешна дата',
    form_constraint_dependon =>
        "Полето е задължително при условие, че полето '[_1]' е попълнено",
    form_constraint_email =>
        'Полето трябва да съдържа e-mail адрес',
    form_constraint_equal =>
        "Не съвпада със стойността на '[_1]'",
    form_constraint_file      => 'Това не е файл',
    form_constraint_file_mime => 'Неправилен тип на файла',
    form_constraint_file_maxsize =>
        'Размера на файла не може да превишава [_1] байта',
    form_constraint_file_minsize =>
        'Размера на файла трябва да е поне [_1] байта',
    form_constraint_file_size =>
        'Размера на файла трябва да е между [_1] и [_2] байта',
    form_constraint_integer =>
        'Полето трябва да бъде цяло число',
    form_constraint_length =>
        'Дължината трябва да е от [_1] до [_2] символа',
    form_constraint_minlength =>
        'Дължината трябва да е поне [_1] символа',
    form_constraint_minrange =>
        'Трябва да е не по-малко от [_1]',
    form_constraint_minmaxfields => 'Грешна стойност',
    form_constraint_maxlength =>
        'Трябва да е не повече от [_1] символа',
    form_constraint_maxrange =>
        'Трябва да е не повече от [_1]',
    form_constraint_number =>
        'Полето трябва да бъде число',
    form_constraint_printable =>
        'Полето съдържа непечатаеми символи',
    form_constraint_range     => 'Трябва да е между [_1] и [_2]',
    form_constraint_recaptcha => 'Грешка reCAPTCHA',
    form_constraint_regex     => 'Невалидна стойност',
    form_constraint_required  => 'Полето е задължително',
    form_constraint_set =>
        'Полето съдържа грешен избор',
    form_constraint_singlevalue =>
        'Полето приема само единична стойност',
    form_constraint_word =>
        'Полето съдържа небуквени символи',
    form_inflator_compounddatetime => 'Невалидна дата',
    form_inflator_datetime         => 'Невалидна дата',
    form_validator_callback        => 'Грешка при валидация',
    form_transformer_callback =>
        'Грешка при преобразуване',

    form_inflator_imager =>
        'Грешка при отварянето на изображението',
    form_validator_imager_size =>
        'Размера на изображението е твърде голям',
    form_transformer_imager =>
        'Грешка при обработката на изображението',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
