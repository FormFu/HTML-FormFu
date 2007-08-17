use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Button');

my $field_xhtml = qq{<span class="button">
<input type="button" />
</span>};

is( "$field", $field_xhtml, 'stringified field' );

