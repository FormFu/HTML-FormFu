use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;
use Storable qw( dclone );

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

_call_element_defaults( $form, {
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
    } );

# take a deep copy of element_defaults, so we can check they've not been butchered, later
my $element_defaults = dclone( _call_element_defaults( $form ) );

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

like( $form->get_field('bar'), qr/name="bar" [^>]* class="custom"/x );

is( $form->get_field('bar')->get_constraint->type, 'Regex' );

like( $form->get_element( { type => 'Block' } ), qr/div [^>]* class="block"/x );

like( $form->get_element( { type => 'Block' } )->get_field('baz'),
    qr/name="baz" .* class="custom"/x );

is_deeply( $element_defaults, _call_element_defaults( $form ) );

sub _call_element_defaults {
    my $form = shift;

    my $warnings;
    local $SIG{ __WARN__ } = sub { $warnings++ };

    my $result = $form->element_defaults( @_ );

    ok( $warnings, 'a deprecation warning was thrown' );

    return $result;
}
