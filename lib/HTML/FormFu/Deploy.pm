package HTML::FormFu::Deploy;

use strict;

use HTML::FormFu::tt_files;
use File::Copy qw( move );
use File::Spec;
use Carp qw( croak );

use Exporter qw( import );
our @EXPORT_OK = qw( deploy );

our $template_dir = "root";
our $SRC_DATA;
our %FILE;
{
    local $/;
    $SRC_DATA = eval { package HTML::FormFu::tt_files; <DATA> };
}

{
    my $data = $SRC_DATA;

    $data =~ s/__CPAN_HTML_FormFu__END_OF_FILE__.*//s;

    # use look-ahead so the __CPAN_ line isn't removed
    my @data = split /(?=__CPAN_HTML_FormFu__[^\n]+__\n)/, $data;

    for my $item (@data) {
        $item =~ s/__CPAN_HTML_FormFu__([^\n]+)__\n//
            or croak "invalid data file header";

        $FILE{$1} = $item;
    }
}

sub file_list {
    return keys %FILE;
}

sub file_source {
    my $filename = shift
        or croak "filename argument required";

    croak "unknown filename" unless exists $FILE{$filename};

    return $FILE{$filename};
}

sub deploy {
    my $dir;
    if (@_) {
        $dir = shift;
    }
    else {
        warn "using default directory '$template_dir'\n";
        $dir = $template_dir;
    }

    if ( !-d $dir ) {
        warn "creating directory '$dir'\n";
        mkdir $dir or croak $@;
    }

    for my $filename ( keys %FILE ) {
        my $path = File::Spec->catfile( $dir, $filename );

        if ( -f $path ) {
            my $bck = $path . ".bck";
            warn "file '$path' already exists, backing up to $bck\n";
            my $ok = move( $path, $bck );
            if ( !$ok ) {
                warn "failed to backup, skipping file\n$@\n";
                next;
            }
        }

        my $ok = open my $fh, '>', $path;
        if ( !$ok ) {
            warn "failed to open '$path', skipping file\n$@\n";
            next;
        }
        binmode $fh;
        print $fh $FILE{$filename};
        close $fh;
    }
    return;
}

1;
