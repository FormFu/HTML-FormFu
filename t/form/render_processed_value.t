use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/form/render_processed_value.yml');

$form->process( {
    foo => '27/04/2007',
    bar => 'hello',
} );

# inflator has run
isa_ok( $form->params->{foo}, 'DateTime' );

# filter has run
is( $form->params->{foo}->year, '2006' );
is( $form->params->{bar}, 'HELLO' );

# deflator is run during render()
# maintains filtered value
like( $form->get_field('foo')->render, qr|value="27/04/2006"| );

# maintains filtered value
like( $form->get_field('bar')->render, qr/value="HELLO"/ );
