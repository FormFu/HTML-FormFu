use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Webaddress');

# Valid
{
    $form->process({ foo => 'http://www.perl.org' });

    ok( $form->valid('foo') );
}

# Valid
{
    $form->process({ foo => 'https://www.perl.org' });

    ok( $form->valid('foo') );
}

# Valid
{
    $form->process({ foo => 'http://perl.org' });

    ok( $form->valid('foo') );
}

# Valid
{
    $form->process({ foo => 'http://www.perl.org:80' });

    ok( $form->valid('foo') );
}

# Valid
{
    $form->process({ foo => 'http://search.cpan.org/~abigail/Regexp-Common-2.120/lib/Regexp/Common/URI/RFC2396.pm' });

    ok( $form->valid('foo') );
}

# Invalid
{
    $form->process({ foo => 'ftp://www.perl.org' });

    ok( $form->has_errors('foo') );
}

# Invalid
{
    $form->process({ foo => 'perl' });

    ok( $form->has_errors('foo') );
}
