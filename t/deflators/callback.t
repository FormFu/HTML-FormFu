use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 'lib';

my $original_foo = "abc123";
my $deflated_foo = "ABC123";

my $original_bar = "abcdef";
my $deflated_bar = "ABCdef";

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element({
    name      => 'foo',
    default  => $original_foo,
    deflator => {
        type     => 'Callback',
        callback => sub { return uc($_[0]) },
    },
});

$form->element({
    name     => 'bar',
    default  => $original_bar,
    deflator => {
        type      => 'Callback',
        callback => 'DeflatorCallback::my_def',
    },
});

$form->process;

like( $form->get_field('foo'), qr/\Q$deflated_foo/ );
like( $form->get_field('bar'), qr/\Q$deflated_bar/ );

{

    package DeflatorCallback;
    use strict;
    use warnings;

    sub my_def {
        my ($value) = @_;

        $value =~ tr/abc/ABC/;

        return $value;
    }
}
