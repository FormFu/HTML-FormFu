use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->config_callback( {
        plain_value => sub {
            return if !defined $_;
            s/Foo/Bar/;
            }
    } );

$form->load_config_file('t/form/config_callback.yml');

is( $form->get_field('foo')->label, 'Bar' );
