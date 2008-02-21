use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use DateTime;

{
    my $today = DateTime->today;
    my $form = HTML::FormFu->new;
    my $e = $form->element('Date');
    $e->name('foo')->default_natural( 'today' );

    $form->process;

    for( qw( day month year ) ) {
        is( $e->$_->{ default }, $today->$_ )
    }
}

