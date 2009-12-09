use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu::MultiForm;
use Crypt::CBC ();
use Storable qw/ thaw /;
use YAML::XS qw/ LoadFile /;

my $yaml_file = 't/multiform/multiform.yml';

my $multi = HTML::FormFu::MultiForm->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$multi->load_config_file($yaml_file);

$multi->process( {
        foo    => 'abc',
        submit => 'Submit',
    } );

ok( $multi->current_form->submitted_and_valid );

like( "$multi", qr|<input name="bar" type="text" />| );

# internals alert!
# decrypt the hidden value, and check it contains the expected data

my $form2 = $multi->next_form;

my $value = $form2->get_field( { name => $multi->default_multiform_hidden_name } )->default;

my $yaml = LoadFile($yaml_file);

my $cbc = Crypt::CBC->new( %{ $yaml->{crypt_args} } );

my $decrypted = $cbc->decrypt_hex($value);

my $data = thaw($decrypted);

is( $data->{current_form}, 2 );

ok( grep { $_ eq 'foo' } @{ $data->{valid_names} } );
ok( grep { $_ eq 'submit' } @{ $data->{valid_names} } );

is( $data->{params}{foo},    'abc' );
is( $data->{params}{submit}, 'Submit' );

