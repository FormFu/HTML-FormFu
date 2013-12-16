use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Date')->name('foo');

$field->deflator( { type => 'Callback', callback => 'A::epoch2datetime' } );

$form->default_values( { foo => time() } );

eval { $form->process; };

ok( !$@ );

package A;
use DateTime;

sub epoch2datetime {
    my ($value) = @_;

    return DateTime->from_epoch( epoch => $value );
}
