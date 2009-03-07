use strict;
use warnings;
use utf8;

use Test::More tests => 2;

use lib 't/lib';
use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/form/languages.yml');

# Invalid
{
    $form->process( {
            bar => 'foo',
        } );

    ok( !$form->submitted_and_valid );
    
    like( $form, qr/\QFeld muss ausgefüllt sein/ );
}

