use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';

my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->localize_class('HTMLFormFu::I18N')->id('form')->auto_label('label_%n');

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_label('label_%f_%n');

like( $form->get_field('foo'), qr!<label>Foo label</label>! );

like( $form->get_field('bar'), qr!<label>Bar label</label>! );
