use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Select')->name('foo')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ] ] );

# check options() without arguments returns an arrayref

{
    my $opts = $field->options;
    
    is( scalar @$opts, 2 );
    
    is( $opts->[0]->{label}, 'One' );
    is( $opts->[0]->{value}, 1 );
    
    is( $opts->[1]->{label}, 'Two' );
    is( $opts->[1]->{value}, 2 );
}

# check that the last call to options() didn't have any side-effects

{
    my $opts = $field->options;
    
    is( scalar @$opts, 2 );
    
    is( $opts->[0]->{label}, 'One' );
    is( $opts->[0]->{value}, 1 );
    
    is( $opts->[1]->{label}, 'Two' );
    is( $opts->[1]->{value}, 2 );
}
