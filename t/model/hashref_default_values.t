use strict;
use warnings;

use Test::More tests => 36;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Checkbox')->name('bar')->value('y');

$form->auto_fieldset(1);

$form->default_model('HashRef');

$form->populate(
    {
        elements => [
            {
                type         => "DateTime",
                name         => "datetime",
                auto_inflate => 1,
                year         => { list => [1999] }
            },
            {
                name     => "inflator",
                deflator => { type => 'Strftime', strftime => '%F %H:%M' },
                inflator =>
                  { type => "DateTime", parser => { strptime => '%F' } }
            },
            {
                type        => "Repeatable",
                nested_name => "many",
                elements    => [
                    { name => "id" },
                    {
                        type     => "Block",
                        name     => "nested",
                        elements => [ { type => "Text", name => "foo" } ]
                    }
                ]
            },
            {
                type    => "Select",
                name    => "single-select",
                options => [ [qw(1 foo)], [qw(2 bar)] ]
            },
            {
                type    => "Select",
                name    => "multi-select",
                options => [ [qw(1 foo)], [qw(2 bar)] ]
            },
            {
                type        => "Block",
                nested_name => "nested",
                elements    => [ { type => "Text", name => "foo" } ]
            },
            {
                type     => "Multi",
                name     => "address",
                elements => [ { name => "street" }, { name => "number" } ]
            },
            {
                type     => "Multi",
                name     => "address-split",
                elements => [ { name => "street" }, { name => "number" } ],
                deflators => [ { type => "CompoundSplit" } ]
            },
            {
                type => "SimpleTable",
                rows => [ [ { name => "table1" } ] ]
            }
        ]
    }
);


for ( 0 .. 1 ) {

    $form->auto_fieldset($_);
    $form->model->default_values(
        {
            datetime => '30-08-1999 22:00',
            bar      => 'y',
            many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
            'single-select' => 1,
			'inflator' => '2008-09-22',
            'multi-select'  => [ 1, 2 ],
            nested          => { foo => "bar" },
            address         => { street => "Lombardstreet", number => 22 },
            'address-split' => "Lombardstreet 22",
            table1          => "test"
        }
    );

    $form->process;

    like( $form->get_field('datetime_minute'),
        qr/<option value="00" selected="selected">00<\/option>/ );
    like( $form->get_field('datetime_hour'),
        qr/<option value="22" selected="selected">22<\/option>/ );
    like( $form->get_field('datetime_year'),
        qr/<option value="1999" selected="selected">1999<\/option>/ );

    like( $form->get_field('bar'), qr/value="y"/ );
    like( $form->get_field('bar'), qr/checked="checked"/ );

    like( $form->get_field('single-select'),
        qr/value="1" selected="selected"/ );
    like( $form->get_field('single-select'), qr/value="2">/ );

    like( $form->get_field('multi-select'), qr/value="1" selected="selected"/ );
    like( $form->get_field('multi-select'), qr/value="2" selected="selected"/ );

    like( $form->get_field('address'),
        qr/name="address.street" type="text" value="Lombardstreet"/ );
    like( $form->get_field('address'),
        qr/name="address.number" type="text" value="22"/ );

    like( $form->get_field('address-split'),
        qr/name="address-split.street" type="text" value="Lombardstreet"/ );
    like( $form->get_field('address-split'),
        qr/name="address-split.number" type="text" value="22"/ );

    like( $form->get_field('table1'),
        qr/name="table1" type="text" value="test"/ );

    like(
        $form->get_all_element( { nested_name => 'many' } ),
        qr/name="many.id_1" type="text" value="1"/
    );
    like(
        $form->get_all_element( { nested_name => 'many' } ),
        qr/name="many.id_2" type="text" value="2"/
    );
    like(
        $form->get_all_element( { nested_name => 'many' } ),
        qr/name="many.foo_1" type="text" value="bar"/
    );
    like(
        $form->get_all_element( { nested_name => 'many' } ),
        qr/name="many.foo_2" type="text" value="baz"/
    );

}
