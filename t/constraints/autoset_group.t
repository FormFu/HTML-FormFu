use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# Autoset on Select with optgroups

my $field = $form->element('Select')->name('foo');

$field->options( [
        ['item 1'],
        { value => 'item 2', },
        { group => [ ['item 3'], { value => 'item 4', } ], },
        ['item 5'],
        { group => [ { value => 'item 6', }, ['item 7'], ], },
    ] );

$field->constraint('AutoSet');

# Valid
{
    $form->process( { foo => 'item 6', } );

    # Constraint set has 7 values
    is_deeply(
        $form->get_constraint->set,
        [   'item 1', 'item 2', 'item 3', 'item 4', 'item 5', 'item 6', 'item 7'
        ],
    );

    ok( $form->valid('foo') );
}

