use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar')->auto_error_message('form_default_error');

$form->constraint('Number');

$form->process({
    foo => 'a',
    bar => 'b',
    });

like(
    $form->get_field('foo'),
    qr!This field must be a number!
);

like(
    $form->get_field('bar'),
    qr!Invalid input!
);
