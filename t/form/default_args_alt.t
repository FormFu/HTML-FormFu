use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use Storable qw( dclone );

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/form/default_args_alt.yml');

# longest match - 'not_in_multi' longer then 'is_input'
my $foo = $form->get_field( { name => 'foo' } );
like( $foo->attrs->{class}, qr/not_in_multi/ );

# Input within the Multi does not get the 'not_in_multi' class
my $bar = $form->get_field( { name => 'bar' } );
like( $bar->attrs->{class}, qr/is_input/ );

is( "$form", <<HTML );
<form action="" method="post">
<div>
<input name="foo" type="text" class="not_in_multi" />
</div>
<div>
<span class="elements">
<input name="multi.bar" type="text" class="is_input" />
</span>
</div>
</form>
HTML
