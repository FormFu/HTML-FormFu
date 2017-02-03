package HTML::FormFu::I18N::tr;

use utf8;

use strict;
# VERSION

use Moose;
extends 'HTML::FormFu::I18N';

our %Lexicon = (
    form_error_message =>
        'Form içeriğiyle ilgili bir hata oluştu. Hata detaylarını formda bulabilirsiniz',
    form_constraint_allornone => 'Hata',
    form_constraint_ascii     => 'Bu alan ASCII olmayan bir karakter içeriyor',
    form_constraint_autoset   => 'Bu alan geçersiz bir tercih içeriyor',
    form_constraint_bool      => 'Bu alana mantıksal bir değer girmelisiniz',
    form_constraint_callback  => 'Geçersiz girdi',
    form_constraint_datetime  => 'Geçersiz tarih',
    form_constraint_dbic_unique => 'Bu kayıt halihazırda veritabanında bulunuyor',
    form_constraint_dependon =>
        "'[_1]' alanını doldurduğunuz için bu alanı da doldurmalısınız",
    form_constraint_email        => 'Bu alana bir e-mail adresi girmelisiniz',
    form_constraint_equal        => "Bu değer '[_1]' ile eşleşmiyor",
    form_constraint_file         => 'Bu bir dosya değil',
    form_constraint_file_mime    => 'Dosya türü geçerli değil',
    form_constraint_file_maxsize => 'Dosya boyutu [_1] bayttan büyük olmamalıdır',
    form_constraint_file_minsize => 'Dosya boyutu [_1] bayttan küçük olmamalıdır',
    form_constraint_file_size =>
        'Dosya boyutu [_1] ila [_2] bayt arasında olmalıdır',
    form_constraint_integer => 'Bu alana bir tam sayı girmelisiniz',
    form_constraint_length  =>
        'Bu alandaki metnin uzunluğu [_1] ila [_2] karakter arasında olmalıdır',
    form_constraint_minlength    => 'Bu alana en az [_1] karakter girmelisiniz',
    form_constraint_minrange     => 'Bu alan en az [_1] olmalıdır',
    form_constraint_minmaxfields => 'Geçersiz girdi',
    form_constraint_maxlength => 'Bu alana en çok [_1] karakter girebilirsiniz',
    form_constraint_maxrange  => 'Bu alan en çok [_1] olmalıdır',
    form_constraint_number    => 'Bu alana bir sayı girmelisiniz',
    form_constraint_printable => 'Bu alan gösterilemeyen karakterler içeriyor',
    form_constraint_range     => 'Bu alan [_1] ila [_2] arasında olmalıdır',
    form_constraint_recaptcha => 'reCAPTCHA hatası',
    form_constraint_regex     => 'Geçersiz girdi',
    form_constraint_repeatable_any => "'[_1]' alanlarından en az biri gereklidir",
    form_constraint_required  => 'Bu alan gereklidir',
    form_constraint_set       => 'Bu alan geçersiz bir tercih içeriyor',
    form_constraint_singlevalue    => 'Bu alan sadece bir değer kabul ediyor',
    form_constraint_word           => 'Bu alan harf olmayan karakterler içeriyor',
    form_inflator_compounddatetime => 'Geçersiz tarih',
    form_inflator_datetime         => 'Geçersiz tarih',
    form_validator_callback        => 'Doğrulayıcı hatası',
    form_transformer_callback      => 'Dönüştürücü hatası',

    form_inflator_imager       => 'Resim dosyasını açarken bir hata oluştu',
    form_validator_imager_size => 'Resim dosyası çok büyük',
    form_transformer_imager    => 'Resim dosyası işlenirken bir hata oluştu',
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
