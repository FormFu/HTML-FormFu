use strict;
use warnings;

use Test::More;
use HTML::FormFu::MultiForm;

eval "use CGI";
if ($@) {
    plan skip_all => 'CGI required';
    exit;
}

plan tests => 13;

# Copied from CGI.pm - http://search.cpan.org/perldoc?CGI

%ENV = (
    %ENV,
    'SCRIPT_NAME'       => '/test.cgi',
    'SERVER_NAME'       => 'perl.org',
    'HTTP_CONNECTION'   => 'TE, close',
    'REQUEST_METHOD'    => 'POST',
    'SCRIPT_URI'        => 'http://www.perl.org/test.cgi',
    'CONTENT_LENGTH'    => 163,
    'SCRIPT_FILENAME'   => '/home/usr/test.cgi',
    'SERVER_SOFTWARE'   => 'Apache/1.3.27 (Unix) ',
    'HTTP_TE'           => 'deflate,gzip;q=0.3',
    'QUERY_STRING'      => '',
    'REMOTE_PORT'       => '1855',
    'HTTP_USER_AGENT'   => 'Mozilla/5.0 (compatible; Konqueror/2.1.1; X11)',
    'SERVER_PORT'       => '80',
    'REMOTE_ADDR'       => '127.0.0.1',
    'CONTENT_TYPE'      => 'multipart/form-data; boundary=xYzZY',
    'SERVER_PROTOCOL'   => 'HTTP/1.1',
    'PATH'              => '/usr/local/bin:/usr/bin:/bin',
    'REQUEST_URI'       => '/test.cgi',
    'GATEWAY_INTERFACE' => 'CGI/1.1',
    'SCRIPT_URL'        => '/test.cgi',
    'SERVER_ADDR'       => '127.0.0.1',
    'DOCUMENT_ROOT'     => '/home/develop',
    'HTTP_HOST'         => 'www.perl.org'
);

my $q;

{
    my $file = 't/multiform-misc-file-client-side.txt';
    local *STDIN;
    open STDIN,
        "<", $file
        or die "missing test file $file";
    binmode STDIN;
    $q = CGI->new;
}

# submit form 1

my $yaml_file = 't/multiform-misc-file-client-side.yml';
my $form2_hidden_value;

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process($q);

    my $form = $multi->current_form;

    ok( $form->submitted_and_valid );

    my $file = $form->param('hello_world');

    is( $file->filename,                'hello_world.txt' );
    is( $file->headers->content_length, 13 );
    is( $file->headers->content_type,   'text/plain' );
    is( $file->slurp,                   "Hello World!\n" );

    ok( $file->parent == $form );

    # next_form
    my $form_2 = $multi->next_form;

    my $hidden_field = $form_2->get_field(
        { name => $multi->default_multiform_hidden_name } );

    $form2_hidden_value = $hidden_field->default;
}

# submit form 2

{
    my $multi = HTML::FormFu::MultiForm->new;

    $multi->load_config_file($yaml_file);

    $multi->process( {
            $multi->default_multiform_hidden_name => $form2_hidden_value,
            bar                                   => 'def',
        } );

    ok( $multi->complete );

    my $form = $multi->current_form;

    is( $form->param('bar'), 'def' );

    # still got uploaded file
    my $file = $form->param('hello_world');

    is( $file->filename,                'hello_world.txt' );
    is( $file->headers->content_length, 13 );
    is( $file->headers->content_type,   'text/plain' );
    is( $file->slurp,                   "Hello World!\n" );

    ok( $file->parent == $form );
}

