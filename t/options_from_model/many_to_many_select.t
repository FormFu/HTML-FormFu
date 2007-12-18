use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBIx::Class 0.08002";
    if ($@) {
        plan skip_all => 'DBIx::Class required';
        exit;
    }
}

plan tests => 1;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;
use Test::MockObject;
my $context = Test::MockObject->new();
new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/options_from_model/many_to_many_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');
$context->mock( model => sub { $schema->resultset( 'Band') } );
$form->stash( { context => $context } );

my $user_rs = $schema->resultset('User');
my $band_rs = $schema->resultset('Band');

{
    # user 1
    my $u1 = $user_rs->create({ name => 'John' });
    # user 2
    my $u2 = $user_rs->create({ name => 'Paul' });
    # band 1
    my $b1 = $u1->add_to_bands({ band => 'the beatles' });
    # user 2 => band 2
    $u2->add_to_bands({ band => 'wings' });
    # user 2 => band 1
    $u2->add_to_bands( $b1 );
    # band 3
    $band_rs->create({ band => 'the kinks' });
}


{
    $form->process;
    is_deeply(
        $form->get_field('bands')->_options,
        [
          {
            'label_attributes' => {},
            'value' => '1',
            'label' => 'the beatles',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '2',
            'label' => 'wings',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '3',
            'label' => 'the kinks',
            'attributes' => {}
          }
        ], 
        "Options set from the model"
    );
}
