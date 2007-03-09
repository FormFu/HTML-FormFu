use strict;
use warnings;
use File::Find;
use lib 'lib';

my $template_dir = "root";

if (! -f 'Makefile.PL') {
    die <<END
Can't see the Makefile.PL file:
This program must be run within the HTML-FormFu distribution folder.
END
}

if (! -d $template_dir) {
    die <<END;
Template source directory '$template_dir' missing.
END
}

###

open my $pm_fh, '>', "lib/HTML/FormFu/tt_files.pm"
    or die "failed to open: $!";
binmode $pm_fh;

print $pm_fh <<PM;
package HTML::FormFu::tt_files;

=pod

This package should only be used by L<HTML::FormFu::Deploy>.

It contains the data needed to generate the T<TT|Template> template files. 
This file should only be updated using the update_pm_from_templates.pl file, 
which is only available from the subversion repository.

update_pm_from_templates.pl must always be run before creating a distribution 
for release.

=cut

1;
__DATA__
PM

find( \&parse_src_dir, $template_dir );

print $pm_fh "__CPAN_HTML_FormFu__END_OF_FILE__\n";

close $pm_fh;

sub parse_src_dir {
    my $file = $File::Find::name;
    
    return if $file =~ m|/\.svn\b|;
    return if $file eq $template_dir;
    
    $file =~ s|$template_dir/||;
    
    printf $pm_fh "__CPAN_HTML_FormFu__%s__\n", $file;
    
    open my $fh, '<', $_
        or die "failed to open file '$File::Find::name': $!";
    binmode $fh;
    
    my $slurp = do { local $/; <$fh> };
    
    print $pm_fh "$slurp";
    close $fh;
}
