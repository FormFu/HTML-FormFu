use strict;

package HTML::FormFu::I18N::zh_cn;
# ABSTRACT: Chinese

use utf8;

use Moose;
extends 'HTML::FormFu::I18N';

our %Lexicon = (
    form_error_message        => '提交内容错误',
    form_constraint_allornone => '错误',
    form_constraint_ascii     => '含有非ASCII字符',
    form_constraint_autoset   => '无效选项',
    form_constraint_bool      => '不是布尔值',
    form_constraint_callback  => '无效输入',
    form_constraint_datetime  => '无效日期',
    form_constraint_dependon =>
        "如果'[_1]'不为空，此字段也不能为空",
    form_constraint_email          => '不含邮件地址',
    form_constraint_equal          => "与'[_1]'值不符",
    form_constraint_file           => '不是文件',
    form_constraint_file_mime      => '无效的文件类型',
    form_constraint_file_maxsize   => '文件不能超过[_1]字节',
    form_constraint_file_minsize   => '文件不能少于[_1]字节',
    form_constraint_file_size      => '文件大小必须在[_1]和[_2]之间',
    form_constraint_integer        => '不是数字',
    form_constraint_length         => '长度必须在[_1]和[_2]之间',
    form_constraint_minlength      => '至少[_1]个字符',
    form_constraint_minrange       => '至少[_1]',
    form_constraint_minmaxfields   => '无效输入',
    form_constraint_maxlength      => '至多[_1]个字符',
    form_constraint_maxrange       => '至多[_1]',
    form_constraint_number         => '不是数字',
    form_constraint_printable      => '含有不可打印字符',
    form_constraint_range          => '必须在[_1]和[_2]之间',
    form_constraint_recaptcha      => 'reCAPTCHA错误',
    form_constraint_regex          => '无效输入',
    form_constraint_required       => '不能为空',
    form_constraint_set            => '无效选项',
    form_constraint_singlevalue    => '不是单值',
    form_constraint_word           => '不是单词',
    form_inflator_compounddatetime => '无效日期',
    form_inflator_datetime         => '无效日期',
    form_validator_callback        => 'Validator错误',
    form_transformer_callback      => 'Transformer错误',

    form_inflator_imager       => '打开图像文件错误',
    form_validator_imager_size => '图像文件太大',
    form_transformer_imager    => '处理图像文件错误',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
