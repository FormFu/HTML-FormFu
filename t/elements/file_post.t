use strict;
use warnings;

use Test::More;
use HTML::FormFu;

eval "use CGI";
if ($@) {
    plan skip_all => 'CGI required';
    exit;
}

plan tests => 18;

# Copied from CGI.pm - http://search.cpan.org/perldoc?CGI

%ENV = (
    %ENV,
    'SCRIPT_NAME'       => '/test.cgi',
    'SERVER_NAME'       => 'perl.org',
    'HTTP_CONNECTION'   => 'TE, close',
    'REQUEST_METHOD'    => 'POST',
    'SCRIPT_URI'        => 'http://www.perl.org/test.cgi',
    'CONTENT_LENGTH'    => 3458,
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
    my $file = 't/elements/file_post.txt';
    local *STDIN;
    open STDIN,
        "<", $file
        or die "missing test file $file";
    binmode STDIN;
    $q = CGI->new;
}

my $form = HTML::FormFu->new( {
        action   => 'http://www.perl.org/test.cgi',
        elements => [
            { type => 'Text', name => 'multiple' },
            { type => 'File', name => 'multiple' },
            { type => 'File', name => 'multiple' },
            { type => 'File', name => 'hello_world' },
            { type => 'File', name => 'does_not_exist_gif' },
            { type => 'File', name => '100x100_gif' },
            { type => 'File', name => '300x300_gif' },
        ],
    } );

$form->process($q);

{
    my $multiple = $form->params->{multiple};

    is( @$multiple, 3 );

    my ( $m1, $m2, $m3 ) = @$multiple;

    ok( !ref $m1 );
    is( $m1, 'foo' );

    isa_ok( $m2, 'HTML::FormFu::Upload' );
    is( $m2->filename,                    'one.txt' );
    is( $m2->headers->{'Content-Length'}, 4 );
    is( $m2->headers->{'Content-Type'},   'text/plain' );
    is( $m2->slurp,                       "One\n" );

    isa_ok( $m3, 'HTML::FormFu::Upload' );
    is( $m3->filename,                    'two.txt' );
    is( $m3->headers->{'Content-Length'}, 5 );
    is( $m3->headers->{'Content-Type'},   'text/plain' );
    is( $m3->slurp,                       "Two!\n" );
}

{
    my $value = $form->params->{hello_world};

    isa_ok( $value, 'HTML::FormFu::Upload' );
    is( $value->filename,                    'hello_world.txt' );
    is( $value->headers->{'Content-Length'}, 13 );
    is( $value->headers->{'Content-Type'},   'text/plain' );
    is( $value->slurp,                       "Hello World!\n" );
}

