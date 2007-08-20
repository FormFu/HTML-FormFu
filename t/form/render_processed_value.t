use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new->render_processed_value(1);

my $e = $form->element('Text')->name('foo');

$e->deflator('Strftime')->strftime('%d/%m/%Y');
$e->filter('Regex')->match(2007)->replace(2006);
$e->inflator('DateTime')->parser( strptime => '%d/%m/%Y' );

$form->process( { foo => '27/04/2007', } );

# inflator has run
isa_ok( $form->params->{foo}, 'DateTime' );

# filter has run
is( $form->params->{foo}->year, '2006' );

# deflator is run during render()
# maintains filtered value
like( $e->render, qr|value="27/04/2006"| );
