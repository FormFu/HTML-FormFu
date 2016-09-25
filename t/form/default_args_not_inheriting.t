use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use Storable qw( dclone );

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->default_args( {
        elements => {
            '+Block'    => { auto_id    => 'ID' },
            SimpleTable => { attributes => { class => 'custom class' } },
        },
    } );

# take a deep copy of element_defaults, so we can check they've not been butchered, later

my $default_args = dclone( $form->default_args );

$form->populate( {
        elements => [ {
                type => 'SimpleTable',
                name => 'foo',
            },
        ],
    } );

my $table = $form->get_all_element( { type => 'SimpleTable' } );

like( $table, qr/table [^>]*class="[^"]*custom class[^"]*"/ );

is( $table->auto_id, undef );

# original default_args hashref hasn't been butchered
is_deeply( $default_args, $form->default_args );
