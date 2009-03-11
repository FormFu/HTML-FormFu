use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->default_model('HashRef');

$form->load_config_file('t/model/hashref_multi_within_rep.yml');


ok($form->model->default_values({
	id => 1, title => "foo"
}), "empty repeatable block");


$form->model->default_values({
	id => 1, title => "foo", count => 2, recall_schedules => [{ id => 2, start => {startdate => '30.08.1999', starttime => '9:00' } }, { id => 3}]
});

$form->model->options(1);

is_deeply($form->model->create,
	{
	          'count' => 2,
	          'id' => 1,
	          'title' => 'foo',
	          'select' => { value => undef, label => undef },
	          'recall_schedules' => [
	                                {
	                                  'id' => 2,
	                                  'start' => {
	                                             'starttime' => '9:00',
	                                             'startdate' => '30.08.1999'
	                                           }
	                                },
	                                {
	                                  'id' => 3,
	                                  'start' => {
	                                             'starttime' => undef,
	                                             'startdate' => undef
	                                           }
	                                }
	                              ]
	        }
	);