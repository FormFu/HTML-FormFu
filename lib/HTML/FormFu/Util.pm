package HTML::FormFu::Util;

use strict;

use HTML::FormFu::Literal;
use Scalar::Util qw( blessed );
use Exporter qw/ import /;
use Carp qw/ croak /;

our @EXPORT_OK = qw/
    append_xml_attribute
    has_xml_attribute
    remove_xml_attribute
    _parse_args
    require_class
    xml_escape
    literal
    _filter_components
    _get_elements
    process_attrs
    split_name
    _merge_hashes
    /;

sub _filter_components {
    my ( $args, $components ) = @_;

    for my $name ( keys %$args ) {
        # get_errors() handles this itself
        next if $name eq 'forced';

        my $value;

        @$components = grep {
                   $_->can($name)
                && defined( $value = $_->$name )
                && $value eq $args->{$name}
        } @$components;
    }

    return $components;
}

sub _get_elements {
    my ( $args, $elements ) = @_;

    for my $name ( keys %$args ) {
        my $value;

        @$elements = grep {
                   $_->can($name)
                && defined( $value = $_->$name )
                && $value eq $args->{$name}
        } @$elements;
    }

    return $elements;
}

sub append_xml_attribute {
    my ( $attrs, $key, $value ) = @_;

    croak '$attrs arg must be a hash reference'
        if ref $attrs ne 'HASH';

    my %dispatcher = _append_subs();

    if ( exists $attrs->{$key} && defined $attrs->{$key} ) {
        my $orig = 'string';
        $orig = 'literal'
            if blessed $attrs->{$key}
                && $attrs->{$key}->isa('HTML::FormFu::Literal');

        my $new = 'string';
        $new = 'literal'
            if blessed $value
                && $value->isa('HTML::FormFu::Literal');

        $attrs->{$key} = $dispatcher{$orig}->{$new}->( $attrs->{$key}, $value );
    }
    else {
        $attrs->{$key} = $value;
    }

    return $attrs;
}

sub _append_subs {
    return (
        literal => {
            string => sub { $_[0]->push( xml_escape(" $_[1]") ); return $_[0] },
            literal => sub { $_[0]->push(" $_[1]"); return $_[0] },
        },
        string => {
            string => sub { $_[0] .= " $_[1]"; return $_[0] },
            literal =>
                sub { $_[1]->unshift( xml_escape("$_[0] ") ); return $_[1] },
        },
    );
}

sub has_xml_attribute {
    my ( $attrs, $key, $value ) = @_;

    croak '$attrs arg must be a hash reference'
        if ref $attrs ne 'HASH';

    my %dispatcher = _has_subs();

    if ( exists $attrs->{$key} && defined $attrs->{$key} ) {
        my $orig = 'string';
        $orig = 'literal'
            if blessed $attrs->{$key}
                && $attrs->{$key}->isa('HTML::FormFu::Literal');

        my $new = 'string';
        $new = 'literal'
            if blessed $value
                && $value->isa('HTML::FormFu::Literal');

        return $dispatcher{$orig}->{$new}->( $attrs->{$key}, $value );
    }

    return;
}

sub _has_subs {
    return (
        literal => {
            string => sub {
                my $x = "$_[0]";
                my $y = xml_escape("$_[1]");
                return
                       $x =~ /^\Q$y\E ?/
                    || $x =~ / \Q$y\E /
                    || $x =~ / ?\Q$y\E$/;
            },
            literal => sub {
                my $x = "$_[0]";
                my $y = "$_[1]";
                return
                       $x =~ /^\Q$y\E ?/
                    || $x =~ / \Q$y\E /
                    || $x =~ / ?\Q$y\E$/;
            },
        },
        string => {
            string => sub {
                my ( $x, $y ) = @_;
                return
                       $x =~ /^\Q$y\E ?/
                    || $x =~ / \Q$y\E /
                    || $x =~ / ?\Q$y\E$/;
            },
            literal => sub {
                my $x = xml_escape( $_[0] );
                my $y = "$_[1]";
                return
                       $x =~ /^\Q$y\E ?/
                    || $x =~ / \Q$y\E /
                    || $x =~ / ?\Q$y\E$/;
            },
        },
    );
}

sub remove_xml_attribute {
    my ( $attrs, $key, $value ) = @_;

    croak '$attrs arg must be a hash reference'
        if ref $attrs ne 'HASH';

    my %dispatcher = _remove_subs();

    if ( exists $attrs->{$key} && defined $attrs->{$key} ) {
        my $orig = 'string';
        $orig = 'literal'
            if blessed $attrs->{$key}
                && $attrs->{$key}->isa('HTML::FormFu::Literal');

        my $new = 'string';
        $new = 'literal'
            if blessed $value
                && $value->isa('HTML::FormFu::Literal');

        $attrs->{$key} = $dispatcher{$orig}->{$new}->( $attrs->{$key}, $value );
    }
    else {
        $attrs->{$key} = $value;
    }

    return $attrs;
}

sub _remove_subs {
    return (
        literal => {
            string => sub {
                my $x = "$_[0]";
                my $y = xml_escape("$_[1]");
                $x        =~ s/^\Q$y\E ?//
                    || $x =~ s/ \Q$y\E / /
                    || $x =~ s/ ?\Q$y\E$//;
                return literal($x);
            },
            literal => sub {
                my $x = "$_[0]";
                my $y = "$_[1]";
                $x        =~ s/^\Q$y\E ?//
                    || $x =~ s/ \Q$y\E / /
                    || $x =~ s/ ?\Q$y\E$//;
                return literal($x);
            },
        },
        string => {
            string => sub {
                my ( $x, $y ) = @_;
                $x        =~ s/^\Q$y\E ?//
                    || $x =~ s/ \Q$y\E / /
                    || $x =~ s/ ?\Q$y\E$//;
                return $x;
            },
            literal => sub {
                my $x = xml_escape( $_[0] );
                my $y = "$_[1]";
                $x        =~ s/^\Q$y\E ?//
                    || $x =~ s/ \Q$y\E / /
                    || $x =~ s/ ?\Q$y\E$//;
                return literal($x);
            },
        },
    );
}

sub _parse_args {
    my %args = ();

    if ( !@_ ) {
        %args = ();
    }
    elsif ( @_ > 1 ) {
        %args = @_;
    }
    elsif ( ref $_[0] ) {
        %args = %{ $_[0] };
    }
    else {
        %args = ( name => $_[0] );
    }

    return %args;
}

sub require_class {
    my ($class) = @_;

    croak "class argument missing" if !defined $class;

    $class =~ s|::|/|g;
    $class .= ".pm";

    if ( !exists $::INC{$class} ) {
        eval { require $class };
        croak $@ if $@;

        Class::C3::initialize();
    }

    return;
}

sub xml_escape {
    my $val = shift;

    return undef if !defined $val;

    if ( ref $val eq 'HASH' ) {
        my %val = %$val;
        for my $key ( keys %val ) {
            $val{$key} = xml_escape( $val{$key} );
        }
        return \%val;
    }
    elsif ( ref $val eq 'ARRAY' ) {
        my @val = @$val;
        my @new;
        for my $val (@val) {
            push @new, xml_escape($val);
        }
        return \@new;
    }
    elsif ( ref $val ) {
        return "$val";
    }

    return $val if !length $val;

    $val =~ s/&/&#38;/g;
    $val =~ s/"/&#34;/g;
    $val =~ s/'/&#39;/g;
    $val =~ s/</&lt;/g;
    $val =~ s/>/&gt;/g;

    return $val;
}

sub literal {
    return HTML::FormFu::Literal->new(@_);
}

sub process_attrs {
    my ($attrs) = @_;

    eval { my %attrs = %$attrs };
    croak $@ if $@;

    my $xml = join " ", map { sprintf qq{%s="%s"}, $_, $attrs->{$_} }
        sort keys %$attrs;

    $xml = " $xml"
        if length $xml;

    return $xml;
}

sub split_name {
    my ($name) = @_;

    croak "split_name requires 1 arg" if @_ != 1;

    return () if !defined $name;

    if ( $name =~ /^ \w+ \[ /x ) {

        # copied from Catalyst::Plugin::Params::Nested::Expander

        return grep {defined} (
            $name =~ /
            ^  (\w+)      # root param
            | \[ (\w+) \] # nested
        /gx
        );
    }
    elsif ( $name =~ /\./ ) {

        # Copied from CGI::Expand

        # m// splits on unescaped '.' chars. Can't fail b/c \G on next
        # non ./ * -> escaped anything -> non ./ *
        $name =~ m/^ ( [^\\\.]* (?: \\(?:.|$) [^\\\.]* )* ) /gx;
        my $first = $1;
        $first =~ s/\\(.)/$1/g;    # remove escaping

        my (@segments) = $name =~

            # . -> ( non ./ * -> escaped anything -> non ./ * )
            m/\G (?:[\.]) ( [^\\\.]* (?: \\(?:.|$) [^\\\.]* )* ) /gx;

        # Escapes removed later, can be used to avoid using as array index

        return ( $first, @segments );
    }

    return ($name);
}

# sub _merge_hashes copied from Catalyst::Utils::merge_hashes()
# redistributed under the same terms as Perl

sub _merge_hashes {
    my ( $lefthash, $righthash ) = @_;

    return $lefthash unless defined $righthash;
    
    my %merged = %$lefthash;
    for my $key ( keys %$righthash ) {
        my $right_ref = ( ref $righthash->{ $key } || '' ) eq 'HASH';
        my $left_ref  = ( ( exists $lefthash->{ $key } && ref $lefthash->{ $key } ) || '' ) eq 'HASH';
        if( $right_ref and $left_ref ) {
            $merged{ $key } = _merge_hashes(
                $lefthash->{ $key }, $righthash->{ $key }
            );
        }
        else {
            $merged{ $key } = $righthash->{ $key };
        }
    }
    
    return \%merged;
}

1;
