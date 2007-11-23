use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');

$form->constraint('Required');
$form->constraint('Email');

{
    $form->process( { foo => 'cfranks@cpan', } );

    ok( $form->has_errors('foo'), 'foo has errors' );

    like( $form, qr/\QThis field must contain an email address/ );
}

{
    $form->process( { foo => '', } );

    ok( $form->has_errors('foo'), 'foo has errors' );

    like( $form, qr/\QThis field is required/ );
}
