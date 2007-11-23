use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $foo1 = $form->element('Text')->name('foo');
my $foo2 = $form->element('Text')->name('foo');

$form->process( { foo => [qw/ a b /], } );

is( $foo1->render_data->{value}, 'a' );
is( $foo2->render_data->{value}, 'b' );
