use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;
use Storable qw( dclone );
SKIP:
{
    skip
        "Need to figure out alternative way to set default_args() on parent classes\n"
        . "after the move to Moose",
        4;

    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->default_args( {
            elements => {
                Block  => { attributes => { class => 'block' } },
                Multi  => { label      => 'My Label' },
                _Field => { comment    => 'My Comment' },
            },
        } );

# take a deep copy of element_defaults, so we can check they've not been butchered, later

    my $default_args = dclone( $form->default_args );

    $form->populate( {
            elements => [ {
                    type => 'Multi',
                    name => 'foo',
                },
            ],
        } );

    my $multi = $form->get_all_element( { type => 'Multi' } );

    like( $multi, qr/class="[^"]*block[^"]*"/ );

    is( $multi->label, 'My Label' );

    is( $multi->comment, 'My Comment' );

    # original default_args hashref hasn't been butchered
    is_deeply( $default_args, $form->default_args );
}
