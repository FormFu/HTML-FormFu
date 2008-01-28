use strict;
use warnings;

use Test::More tests => 20;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->indicator('my_hidden');

$form->element('Button')->name('my_button')->value(1);
$form->element('Checkbox')->name('my_checkbox1')->value(1)
    ->attrs( checked => 'checked' );
$form->element('Checkbox')->name('my_checkbox2')->value(0);
$form->element('ContentButton')->name('my_contentbutton')->value(1);
$form->element('Hidden')->name('my_hidden')->value(1);
$form->element('Image')->name('my_image')->value(1);

#$form->element('Password')->name('my_password')->value(1)->fill(1);
$form->element('Radio')->name('my_radio1')->value(1)
    ->attrs( checked => 'checked' );
$form->element('Radio')->name('my_radio2')->value(0);
$form->element('Radiogroup')->name('my_radiogroup')->values( [ 1, 0 ] )
    ->attrs( checked => 'checked' );
$form->element('Reset')->name('my_reset')->value(1);
$form->element('Select')->name('my_select')
    ->options( [ [ 0 => 'unsubscribed' ], [ 1 => 'subscribed' ] ] )
    ->attrs( selected => 'selected' );
$form->element('Submit')->name('my_submit')->value(1);
$form->element('Text')->name('my_text')->value(1);
$form->element('Textarea')->name('my_textarea')->value(1);

{
    like( $form->get_field('my_button'),        qr/value="1"/ );
    like( $form->get_field('my_checkbox1'),     qr/value="1"/ );
    like( $form->get_field('my_checkbox2'),     qr/value="0"/ );
    like( $form->get_field('my_contentbutton'), qr/value="1"/ );
    like( $form->get_field('my_hidden'),        qr/value="1"/ );
    like( $form->get_field('my_image'),         qr/value="1"/ );
    like( $form->get_field('my_radio1'),        qr/value="1"/ );
    like( $form->get_field('my_radio2'),        qr/value="0"/ );
    like( $form->get_field('my_radiogroup'),    qr/value="1"/ );
    like( $form->get_field('my_reset'),         qr/value="1"/ );
    like( $form->get_field('my_select'),        qr/value="1"/ );
    like( $form->get_field('my_submit'),        qr/value="1"/ );
    like( $form->get_field('my_text'),          qr/value="1"/ );
    like( $form->get_field('my_textarea'),      qr!>1</textarea>! );
}

# make sure XML of the result object has empty values, not defaults

{
    $form->process( { my_hidden => '', } );

    like( $form->get_field('my_checkbox1'), qr/value="1"/ );
    unlike( $form->get_field('my_checkbox1'), qr/"checked"/ );

    like( $form->get_field('my_checkbox2'), qr/value="0"/ );
    unlike( $form->get_field('my_checkbox2'), qr/"checked"/ );

    like( $form->get_field('my_contentbutton'), qr/value=""/ );
    like( $form->get_field('my_hidden'),        qr/value=""/ );
}

