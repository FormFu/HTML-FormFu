use strict;
use warnings;

use Test::More tests => 3;

use lib 't/lib';
use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->default_model('+HTMLFormFu::MyModel');

my $model = $form->model;

ok( $model == $form->model('HTMLFormFu::MyModel') );

isa_ok( $model, 'HTMLFormFu::MyModel' );
isa_ok( $model, 'HTML::FormFu::Model' );
