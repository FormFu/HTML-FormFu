use Test::More;

eval 'use Test::Pod 1.00';

if ($@) {
    plan skip_all => 'Test::Pod 1.00 required for testing POD';
    exit;
}

if ( -d 'inc' ) {
    plan skip_all => 'inc directory exists - skipping POD tests';
    exit;
}

all_pod_files_ok( all_pod_files('lib') );
