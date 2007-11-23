use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->config_callback( {
        plain_value => sub {
            return if !defined $_;
            s/Foo/Bar/;
            }
    } );

$form->load_config_file('t/form/config_callback.yml');

is( $form->get_field('foo')->label, 'Bar' );
