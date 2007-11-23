use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

=pod

Using auto_fieldset, elements were incorrectly getting the form 
as their parent, not the fieldset

=cut

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset(1);

my $foo = $form->element({ name => 'foo' });

ok( $foo->parent == $form->get_element );

