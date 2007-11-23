use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

# Autoset with multiple values

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->constraint('AutoSet');

# Valid
{
    $form->process( { foo => 'two', } );

    # Constraint set has 3 values
    is_deeply( $form->get_constraint->set, [qw/ one two three /] );

    ok( $form->valid('foo') );
}

# Invalid
{
    $form->process( { foo => 'yes', } );

    ok( $form->has_errors('foo') );
}

# Autoset with a single value

$form->element('Select')->name('bar')->values( [qw/ one /] )
    ->constraint('AutoSet');

# Valid
{
    $form->process( { bar => 'one', } );

    ok( $form->valid('bar') );
}

# Invalid
{
    $form->process( { bar => 'yes', } );

    ok( $form->has_errors('bar') );
}

