use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element_defaults( {
        password => { render_value => 1, },
        text     => { attributes   => { class => 'custom' }, },
        block    => { attributes   => { class => 'block' }, },
    } );

$form->populate( {
        elements => [
            { type => 'password', name => 'foo' },
            { type => 'text',     name => 'bar' },
            { type => 'block',  elements => [
                { type => 'text', name => 'baz' },
                ],
            },
        ],
    } );

is( $form->get_field('foo')->render_value, 1 );

like( $form->get_field('bar'), qr/name="bar" .* class="custom"/x );

like( $form->get_element( { type => 'block' } ), qr/div .* class="block"/x );

like( $form->get_element( { type => 'block' } )->get_field('baz'),
    qr/name="baz" .* class="custom"/x );

