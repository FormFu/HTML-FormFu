use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;
use Storable qw( dclone );

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->default_args( {
        elements => {
            Password => { render_value => 1, },
            Block    => { attributes   => { class => 'block' }, },
            Text     => {
                         attributes => { class => 'custom' },
                         constraint => [
                            {
                                type  => 'Regex',
                                regex => qr/\w/,
                            }
                        ],
            },
        },
        constraints => {
            MaxLength => {
                max => 99,
            },
        },
    } );

# take a deep copy of element_defaults, so we can check they've not been butchered, later

my $default_args = dclone( $form->default_args );

$form->populate( {
        elements => [
            {   type => 'Password',
                name => 'foo',
                constraints => [ { type => 'MaxLength' } ],
            },
            { type => 'Text',     name => 'bar' },
            {   type     => 'Block',
                elements => [ { type => 'Text', name => 'baz' }, ],
            },
        ],
    } );

is( $form->get_field('foo')->render_value, 1 );

is( $form->get_field('foo')->get_constraint->max, 99 );

like( $form->get_field('bar'), qr/name="bar" [^>]* class="custom"/x );

is( $form->get_field('bar')->get_constraint->type, 'Regex' );

like( $form->get_element( { type => 'Block' } ), qr/div [^>]* class="block"/x );

like( $form->get_element( { type => 'Block' } )->get_field('baz'),
    qr/name="baz" .* class="custom"/x );


is_deeply( $default_args, $form->default_args );
