use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use HTML::FormFu;

{

    package MyApp::FormFu;
    use Moose;
    extends 'HTML::FormFu';

    has 'my_attr' => ( is => 'ro', init_arg => 'mine' );
}

my $form;
lives_ok( sub { $form = MyApp::FormFu->new( mine => 'ok' ); },
    "form construction doesn't die" );
ok( $form, 'form constructed ok' );
is( $form->my_attr, 'ok', 'attribute set' );
