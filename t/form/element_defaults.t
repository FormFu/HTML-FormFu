use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element_defaults( {
        Password => { render_value => 1, },
        Text     => { attributes   => { class => 'custom' }, },
        Block    => { attributes   => { class => 'block' }, },
    } );

$form->populate( {
        elements => [
            { type => 'Password', name => 'foo' },
            { type => 'Text',     name => 'bar' },
            {   type     => 'Block',
                elements => [ { type => 'Text', name => 'baz' }, ],
            },
        ],
    } );

is( $form->get_field('foo')->render_value, 1 );

like( $form->get_field('bar'), qr/name="bar" .* class="custom"/x );

like( $form->get_element( { type => 'Block' } ), qr/div .* class="block"/x );

like( $form->get_element( { type => 'Block' } )->get_field('baz'),
    qr/name="baz" .* class="custom"/x );

