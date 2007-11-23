use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->render_processed_value(1);

$form->auto_fieldset( { nested_name => 'foo' } );

my $e = $form->element('Text')->name('bar');

$e->deflator('Strftime')->strftime('%d/%m/%Y');
$e->filter('Regex')->match(2007)->replace(2006);
$e->inflator('DateTime')->parser( strptime => '%d/%m/%Y' );

$form->process( { "foo.bar" => '27/04/2007', } );

my $foo = $form->param("foo.bar");

# inflator has run
isa_ok( $foo, 'DateTime' );

# filter has run
is( $foo->year, '2006' );

# deflator is run during render()
# maintains filtered value
like( $e->render, qr|value="27/04/2006"| );
