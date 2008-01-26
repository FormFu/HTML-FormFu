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

plan tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;
new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/options_from_model/belongs_to.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');
$form->stash( { schema => $schema } );

my $type_rs = $schema->resultset('Type');
my $type2_rs = $schema->resultset('Type2');

{
    # types 
    $type_rs->delete;
    $type_rs->create({ type => 'type 1' });
    $type_rs->create({ type => 'type 2' });
    $type_rs->create({ type => 'type 3' });

    $type2_rs->delete;
    $type2_rs->create({ type => 'type 1' });
    $type2_rs->create({ type => 'type 2' });
    $type2_rs->create({ type => 'type 3' });
}


{
    $form->process;
    is_deeply(
        $form->get_field('type')->_options,
        [
          {
            'label_attributes' => {},
            'value' => '1',
            'label' => 'type 1',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '2',
            'label' => 'type 2',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '3',
            'label' => 'type 3',
            'attributes' => {}
          }
        ], 
        "Options set from the model"
    );
    is_deeply(
        $form->get_field('type2_id')->_options,
        [
          {
            'label_attributes' => {},
            'value' => '1',
            'label' => 'type 1',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '2',
            'label' => 'type 2',
            'attributes' => {}
          },
          {
            'label_attributes' => {},
            'value' => '3',
            'label' => 'type 3',
            'attributes' => {}
          }
        ], 
        "Options set from the model (field name different from relatioship name)"
    );
}
