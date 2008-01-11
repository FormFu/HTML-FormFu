use strict;
use warnings;

use Test::More;
use HTML::FormFu;

eval "use CGI";
if ($@) {
    plan skip_all => 'CGI required';
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
    'CONTENT_LENGTH'    => 206,
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
    my $file = 't/nested/elements/file_post.txt';
    local *STDIN;
    open STDIN,
        "<", $file
        or die "missing test file $file";
    binmode STDIN;
    $q = CGI->new;
}

my $form = HTML::FormFu->new( {
        action   => 'http://www.perl.org/test.cgi',
        auto_fieldset => {
            nested_name => 'foo',
        },
        elements => [
            { type => 'Text', name => 'bar' },
            { type => 'File', name => 'bar' },
        ],
    } );

$form->process($q);

{
    my $values = $form->params->{foo}{bar};

    is( @$values, 2 );

    my ( $v1, $v2 ) = @$values;

    ok( !ref $v1 );
    is( $v1, 'foo' );

    isa_ok( $v2, 'HTML::FormFu::Upload' );
    is( $v2->filename, 'one.txt' );
    is( $v2->size, 4 );
    is( $v2->type, 'text/plain' );
    is( $v2->slurp, "One\n" );
}

