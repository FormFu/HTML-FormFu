use inc::Module::Install 1.00;
use IO::Interactive qw( is_interactive );
use File::Spec;
$|=1;

name 'HTML-FormFu';
perl_version '5.008001';

# required for legacy check below
include_deps 'IO::Interactive' => '0.04';

{
    # check for old non-Moose version
    
    eval { require HTML::FormFu::Element::_Field };
    
    if ( !$@ ) {
        my $path = $INC{'HTML/FormFu/Element/_Field.pm'};
        
        my ( $volume, $dir, $file ) = File::Spec->splitpath( $path );
        
        my @dirs = File::Spec->splitdir( $dir );
        # get rid of HTML/FormFu/Element
        splice @dirs, -4;
        
        my $lib_dir  = File::Spec->catdir( @dirs );
        my $lib_path = File::Spec->catpath( $volume, $lib_dir );
        
        my $msg = <<ERROR;
Files from an older, pre-0.09000 version of HTML-FormFu have been detected
in directory: '$lib_path'.

This will cause problems if you use HTML::FormFu::Preload, and will also
cause spurious warnings during the test suite run.

We strongly recommend you manually remove old HTML-FormFu files before
continuing.

ERROR
        
        eval { require IO::Interactive };
        
        if ( IO::Interactive::is_interactive() ) {
            warn <<WARN;
***Warning***
$msg
Continue?
WARN

            chomp( my $answer = <STDIN> );
            
            if ( $answer !~ /y/i ) {
                die "Remove old HTML-FormFu files and retry\n";
            }
        }
        else {
            die <<ERROR;
***Error***
$msg
Will not continue non-interactively
ERROR

        }
    }
}

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/HTML/FormFu.pm > README' );
}

all_from 'lib/HTML/FormFu.pm';

repository 'git://github.com/fireartist/HTML-FormFu.git';

# this is the lowest version of Exporter I can identify that exports import()
# it's bundled with perl 5.83
# version 5.567 that ships with perl 5.82 is no good
requires 'Exporter' => '5.57';

requires 'Captcha::reCAPTCHA' => 0.93;
requires 'Class::Accessor::Chained::Fast';
requires 'Clone' => '0.31';
requires 'Class::MOP::Method';
requires 'Config::Any' => '0.18'; # 0.10 - supports multi-doc config files
                                  # 0.18 - prefers YAML::XS for YAML
requires 'Crypt::CBC';
requires 'Crypt::DES';
requires 'Data::Visitor' => 0.26; # when it dumped Any::Moose for Moose
requires 'Date::Calc';
requires 'DateTime' => '0.54'; # required for string overloading
requires 'DateTime::Format::Strptime' => '1.2000';  
requires 'DateTime::Format::Builder' => '0.7901'; # fixes memory leaks
requires 'DateTime::Format::Natural';
requires 'DateTime::Locale' => '0.45';
requires 'Email::Valid';
requires 'File::ShareDir';
requires 'Hash::Flatten';
requires 'HTML::Scrubber';
requires 'HTML::TokeParser::Simple' => '3.14';
requires 'HTTP::Headers' => '1.64';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Locale::Maketext';
requires 'Module::Pluggable';
requires 'Moose' => '1.00'; # Reasonable default until we get test results
requires 'MooseX::Aliases';
requires 'MooseX::ChainedAccessors::Accessor' => '0.02'; # for more recent Moose
requires 'MooseX::SetOnce';
requires 'Number::Format';
requires 'Readonly';
requires 'Regexp::Common';
requires 'Path::Class::File';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()
requires 'Template'; # form->start and ->end still require TT
                     # so does t/elements/render_method
requires 'YAML::XS' => '0.32';

test_requires 'CGI'; # for file POST tests
test_requires 'Test::NoWarnings';
test_requires 'Test::More' => '0.92';

tests_recursive( 't' );

no_index directory => 'examples';

install_script('bin/html_formfu_deploy.pl');
install_script('bin/html_formfu_dumpconf.pl');
install_share();

# Developers on MS Windows must have Module::Install::PerlTar installed
# This fixes the problem of tar files having world-writable files,
# which causes PAUSE to choke
eval {
    use_ptar() if author_context && $^O =~/win/i;
};
if ($@) {
    die "Module::Install::PerlTar must be installed when Makefile.PL is run by an author on MS Windows\n";
}

&WriteAll;
