use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/model/hashref_create_repeatable_without_nestedname.yml');

$form->default_model('HashRef');

#$form->model->default_values(
#    {
#        datetime => '30-08-1999 22:00',
#        bar      => 'y',
#        many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
#        'single-select' => 1,
#		'inflator' => '2008-09-22',
#        'multi-select'  => [ 1, 2 ],
#        nested          => { foo => "bar" },
#        address         => { street => "Lombardstreet", number => 22 },
#        'address-split' => "Lombardstreet 22",
#        table1          => "test"
#    });

$form->process;

eval {
    $form->model->create();
};
like( "$@", qr/A Repeatable element without a nested_name attribute cannot be handled by Model::HashRef/, 'error' );

#is_deeply(
#    $form->model->create,
#    {
#        bar  => 'y',
#        many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
#        'single-select'   => 1,
#        'datetime_year'   => 1999,
#        'datetime_minute' => '00',
#        'datetime_month'  => 8,
#        'datetime_day'    => 30,
#        'datetime_hour'   => '22',
#        'datetime'        => '30-08-1999 22:00',
#        'multi-select'    => [ 1, 2 ],
#        nested            => { foo => "bar" },
#        address           => { street => "Lombardstreet", number => 22 },
#        'address-split'   => { street => "Lombardstreet", number => 22 },
#        table1            => "test",
#inflator => '2008-09-22 00:00'
#    }
#);

