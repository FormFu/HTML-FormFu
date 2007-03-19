use strict;
use warnings;

use Test::More;
use HTML::FormFu;

eval "use CGI::Simple";
if ($@) {
    plan skip_all => 'CGI::Simple required';
    exit;
}

plan tests => 8;

# Copied from CGI.pm - http://search.cpan.org/perldoc?CGI

%ENV = (
    %ENV,
    'SCRIPT_NAME'       => '/test.cgi',
    'SERVER_NAME'       => 'perl.org',
    'HTTP_CONNECTION'   => 'TE, close',
    'REQUEST_METHOD'    => 'POST',
    'SCRIPT_URI'        => 'http://www.perl.org/test.cgi',
    'CONTENT_LENGTH'    => 3392,
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
    my $file = 't/element_file_post.txt';
    local *STDIN;
    open STDIN, "<", $file
        or die "missing test file $file";
    binmode STDIN;
    
    no warnings;
    $CGI::Simple::DISABLE_UPLOADS = 0;
    
    $q = CGI::Simple->new;
}

my $form = HTML::FormFu->new( {
        action   => 'http://www.perl.org/test.cgi',
        elements => [
            { type => 'file', name => 'hello_world' },
            { type => 'file', name => 'does_not_exist_gif' },
            { type => 'file', name => '100x100_gif' },
            { type => 'file', name => '300x300_gif' },
            { type => 'file', name => 'multiple' },
        ],
        query_type => 'CGI::Simple',
    } );

$form->process($q);

my $uploads = $form->get_field('multiple')->uploads;

is( $uploads->[0]->headers->{'Content-Length'}, 4 );
is( $uploads->[0]->headers->{'Content-Type'},   'text/plain' );

like( $uploads->[0]->slurp, qr/^One/ );

is( $uploads->[1]->headers->{'Content-Length'}, 4 );
is( $uploads->[1]->headers->{'Content-Type'},   'text/plain' );

like( $uploads->[1]->slurp, qr/^Two/ );

{
    my $headers = $form->get_field('hello_world')->headers;

    is( $headers->{'Content-Length'}, 13 );
    is( $headers->{'Content-Type'},   'text/plain' );
}

