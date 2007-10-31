use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ render_class_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->stash->{foo} = 'bar';

$form->element('Text')->name('foo')->stash->{baz} = 'daz';

is( $form->render->stash->{foo}, 'bar' );

is( $form->get_field('foo')->render->stash->{baz}, 'daz' );
