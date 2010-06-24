use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use DateTime;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/date_default_datetime_args.yml');

$form->process;

{
    my $parser = DateTime::Format::Natural->new;
    my $dt     = $parser->parse_datetime( 'now' );
    $dt->set_time_zone( 'Europe/Berlin' );

    my $foo = $form->get_field('foo');

    my $year       = $dt->year;
    my $year_xhtml = qq{<option value="$year" selected="selected">$year</option>};
    
    cmp_ok( $foo, '=~', $year_xhtml );

    my $hour       = sprintf "%02d", $dt->hour;
    my $hour_xhtml = qq{<option value="$hour" selected="selected">$hour</option>};
    
    cmp_ok( $foo, '=~', $hour_xhtml );
}

{
    my $bar = $form->get_field('bar');
    
    my $year_xhtml = qq{<option value="2001" selected="selected">2001</option>};
    
    cmp_ok( $bar, '=~', $year_xhtml );
}
