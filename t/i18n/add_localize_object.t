use strict;
use warnings;
use Test::More (tests => 4);
use HTML::FormFu;

use lib 't/lib';
use HTMLFormFu::RegressLocalization::en;

my @elements = (
    {
        name      => 'foo',
        # deliberately using formfu's built-in name to trigger
        # text replacement
        label_loc => 'form_constraint_required',
    },
    {
        name      => 'bar',
        # this here can only be replaced by our own l18n handle
        label_loc => 'foobar',
    },
);

{
    my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

    $form->elements(\@elements);

    like( "$form", qr/\bThis field is required\b/, "properly localized" );

    like( "$form", qr/\bfoobar\b/, "properly left untouched" );
}

{
    my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

    $form->add_localize_object(
        HTMLFormFu::RegressLocalization::en->new
    );

    $form->elements(\@elements);

    like( "$form", qr/\bThis field is required\b/, "properly localized" );

    like( "$form", qr/\bFoo blah Baz\b/, "properly localized (added object took effect)" );
}
