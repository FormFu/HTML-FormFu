use strict;
use warnings;

# https://rt.cpan.org/Ticket/Display.html?id=54967

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/bugs/empty_block_with_nested_name.yml');

$form->process( { foo => 'aaa', } );

is_deeply( [ $form->valid ], ['foo'] );
