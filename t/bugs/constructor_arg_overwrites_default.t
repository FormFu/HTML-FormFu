use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({
    elements => {
        type => 'text',
        name => 'foo',
        label_filename => 'foofile',
        }
    });

$form->element({
    type => 'text',
    name => 'bar',
    label_filename => 'barfile',
    });

is( $form->get_field('foo')->label_filename, 'foofile' );
is( $form->get_field('bar')->label_filename, 'barfile' );

is( $form->get_field('foo')->render->{label_filename}, 'foofile' );
is( $form->get_field('bar')->render->{label_filename}, 'barfile' );

