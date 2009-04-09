use strict;
use warnings;

our $count;
BEGIN { $count = 3 };
use Test::More tests => $count;

use HTML::FormFu;
use Number::Format;
use POSIX qw( setlocale LC_NUMERIC );

my $form = HTML::FormFu->new;

$form->load_config_file('t/filters/formatnumber.yml');

my $backup_locale = setlocale(LC_NUMERIC);

SKIP: {    
    # first test the de_DE locale is available
    my $ok = setlocale( LC_NUMERIC, 'de_DE' );
    
    if ( !$ok ) {
        # not available - restore locale and bail
        setlocale( LC_NUMERIC, $backup_locale );
        skip 'de_DE locale not available', $count;
    }
    
    my $format = Number::Format->new;
    
    my $formatted_number = $format->format_number('23000222.22');
    
    isnt( $formatted_number, '23000222.22', 'format of number has changed' );
    
    # restore orginal locale
    setlocale( LC_NUMERIC, $backup_locale );
    
    {
        $form->process( {
            foo => $formatted_number,
        } ); 
        
        ok( $form->submitted_and_valid );
        
        is( $form->param_value('foo'), '23000222.22', 'number no longer in german formatting' );
    }
}
