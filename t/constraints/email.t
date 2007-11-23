use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('Email');

# Valid
{
    $form->process( { foo => 'cfranks@cpan.org', } );

    ok( $form->valid('foo'), 'foo valid' );
}

# Invalid
{
    $form->process( { foo => 'cfranks@cpan', } );

    ok( $form->has_errors('foo'), 'foo has errors' );
}
