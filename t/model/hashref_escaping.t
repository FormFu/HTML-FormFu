use strict;
use warnings;

use Test::More;

use HTML::FormFu;
use HTML::FormFu::Model::HashRef;

my %test = (
    'name_2'       => 'name_2',
    'name_bar_foo' => 'name\\_bar\\_foo',
    'name_2_bar'   => 'name\\_2\\_bar',
    'name_2.bar'   => 'name_2.bar'
);

while ( my ( $k, $v ) = each %test ) {
    is( HTML::FormFu::Model::HashRef::_escape_name($k), $v );
}

is( HTML::FormFu::Model::HashRef::_unescape_name('foo\\_bar'), 'foo_bar' );

is_deeply(
    HTML::FormFu::Model::HashRef::_escape_hash(
        {
            'name_2'       => 'foo',
            'name_bar_foo' => 'bar',
            'name_2_bar'   => 'baz',
            'name_2.bar'   => { 'bas_z' => 1 },
            'bar_z'        => [ { foo_w => 1, foo_2 => 2 } ],
        }
    ),
    {
        'name_2'           => 'foo',
        'name\\_bar\\_foo' => 'bar',
        'name\\_2\\_bar'   => 'baz',
        'name_2.bar'       => { 'bas\\_z' => 1 },
        'bar\\_z'          => [ { 'foo\\_w' => 1, foo_2 => 2 } ]
    }
);

is_deeply(
    HTML::FormFu::Model::HashRef::_unescape_hash(
        {
            'name_2'           => 'foo',
            'name\\_bar\\_foo' => 'bar',
            'name\\_2\\_bar'   => 'baz',
            'name_2.bar'       => { 'bas\\_z' => 1 },
            'bar\\_z'          => [ { 'foo\\_w' => 1, foo_2 => 2 } ]

        }
    ),
    {
        'name_2'       => 'foo',
        'name_bar_foo' => 'bar',
        'name_2_bar'   => 'baz',
        'name_2.bar'   => { 'bas_z' => 1 },
        'bar_z'        => [ { foo_w => 1, foo_2 => 2 } ],
    }
);

my $form = HTML::FormFu->new;
$form->populate(
    {
        elements =>
          [ { name => 'foo' }, { name => 'bar' }, { name => 'foo_bar' } ]
    }
);
$form->process( { foo => 1, bar => 2, foo_bar => 3 } );

is_deeply($form->model('HashRef')->create, { foo => 1, bar => 2, foo_bar => 3 });

done_testing;