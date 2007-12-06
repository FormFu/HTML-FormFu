use strict;
use warnings;
use Scalar::Util qw/ refaddr /;

use Test::More tests => 19;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/clone.yml');

$form->get_all_element({ type => 'Repeatable' })->repeat(2);

$form->process({
    'rep.foo_1' => 'a',
    'rep.bar_1' => '',
    'rep.foo_2' => '',
    'rep.bar_2' => 'd',
    count => 2,
});

isa_ok( $form, 'HTML::FormFu' );

# fieldset

my $fs = $form->get_element;

isa_ok( $fs, 'HTML::FormFu::Element::Fieldset' );

is(
    refaddr( $fs->parent ),
    refaddr( $form ),
);

# hidden field

my $hidden = $form->get_field('count');

isa_ok( $hidden, 'HTML::FormFu::Element::Hidden' );

is(
    refaddr( $hidden->parent ),
    refaddr( $fs ),
);

# repeatable

my $rep = $fs->get_element({ type => 'Repeatable' });

isa_ok( $rep, 'HTML::FormFu::Element::Repeatable' );

is(
    refaddr( $rep->parent ),
    refaddr( $fs ),
);

# block 1

{
    my $block = $rep->get_elements->[0];
    
    my $foo = $block->get_fields->[0];
    
    is(
        refaddr( $foo->parent ),
        refaddr( $block ),
    );
    
    is(
        refaddr( $foo->get_constraint->parent ),
        refaddr( $foo ),
    );
    
    ok( ! $foo->get_error );
    
    my $bar = $block->get_fields->[1];
    
    is(
        refaddr( $bar->parent ),
        refaddr( $block ),
    );
    
    is(
        refaddr( $bar->get_constraint->parent ),
        refaddr( $bar ),
    );
    
    is(
        refaddr( $bar->get_error->parent ),
        refaddr( $bar ),
    );
}

# block 2

{
    my $block = $rep->get_elements->[1];
    
    my $foo = $block->get_fields->[0];
    
    is(
        refaddr( $foo->parent ),
        refaddr( $block ),
    );
    
    is(
        refaddr( $foo->get_constraint->parent ),
        refaddr( $foo ),
    );
    
    is(
        refaddr( $foo->get_error->parent ),
        refaddr( $foo ),
    );
    
    my $bar = $block->get_fields->[1];
    
    is(
        refaddr( $bar->parent ),
        refaddr( $block ),
    );
    
    is(
        refaddr( $bar->get_constraint->parent ),
        refaddr( $bar ),
    );
    
    ok( ! $bar->get_error );
}

