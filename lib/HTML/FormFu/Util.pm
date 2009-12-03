package HTML::FormFu::Util;

use strict;

use HTML::FormFu::Constants qw( $SPACE );
use HTML::FormFu::Literal;
use Scalar::Util qw( blessed reftype );
use Readonly;
use Exporter qw/ import /;
use Carp qw/ croak /;

Readonly my $EMPTY_STR => q{};
Readonly my $SPACE     => q{ };

our $LAST_SUB = $EMPTY_STR;

our @EXPORT_OK = qw(
    DEBUG
    DEBUG_PROCESS
    DEBUG_CONSTRAINTS
    debug
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
);

# the empty prototype () means that when false, all debugging calls
# will be optimised out during compilation

sub DEBUG {
    $ENV{HTML_FORMFU_DEBUG} || 0;
}

sub DEBUG_PROCESS () {
    DEBUG
        || $ENV{HTML_FORMFU_DEBUG_PROCESS}
        || 0;
}

sub DEBUG_CONSTRAINTS {
    DEBUG
        || DEBUG_PROCESS
        || $ENV{HTML_FORMFU_DEBUG_CONSTRAINTS}
        || 0;
}

sub debug {
    my ($message) = @_;

    my ( undef, undef, undef, $sub ) = caller(1);

    require 'Data/Dumper.pm';

    warn "\n" if $sub ne $LAST_SUB;

    if ( @_ > 1 ) {
        warn "$sub()\n" if $sub ne $LAST_SUB;

        while (@_) {
            my $key   = shift;
            my $value = shift;

            if ( ref $value ) {
                $value = Data::Dumper::Dumper($value);
                $value =~ s/^\$VAR1 = //;
            }
            else {
                $value = "'$value'\n";
            }

            warn "$key: $value";
        }
    }
    elsif ( ref $message ) {
        warn "$sub()\n" if $sub ne $LAST_SUB;

        $message = Data::Dumper::Dumper($message);
        $message =~ s/^\$VAR1 = /        /;

        warn "$message\n";
    }
    else {
        warn "$sub\n" if $sub ne $LAST_SUB;

        warn "$message\n";
    }

    $LAST_SUB = $sub;

    return;
}

sub _filter_components {
    my ( $args, $components ) = @_;

    for my $name ( keys %$args ) {

        # get_errors() handles this itself
        next if $name eq 'forced';

        my $value;

        @$components
            = grep {
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
        next unless defined $args->{$name};
        @$elements = grep {
                   $_->can($name)
                && defined( $value = $_->$name )
                && (ref($args->{$name}) eq 'Regexp' ? $value =~ $args->{$name} : $value eq $args->{$name})
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

        if ( blessed $attrs->{$key}
            && $attrs->{$key}->isa('HTML::FormFu::Literal') )
        {
            $orig = 'literal';
        }

        my $new = 'string';

        if ( blessed $value
            && $value->isa('HTML::FormFu::Literal') )
        {
            $new = 'literal';
        }

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
            string => sub {
                $_[0]->push( xml_escape(" $_[1]") );
                return $_[0];
            },
            literal => sub {
                $_[0]->push(" $_[1]");
                return $_[0];
            },
        },
        string => {
            string => sub {
                $_[0] .= " $_[1]";
                return $_[0];
            },
            literal => sub {
                $_[1]->unshift( xml_escape("$_[0] ") );
                return $_[1];
            },
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

        if ( blessed $attrs->{$key}
            && $attrs->{$key}->isa('HTML::FormFu::Literal') )
        {
            $orig = 'literal';
        }

        my $new = 'string';

        if ( blessed $value
            && $value->isa('HTML::FormFu::Literal') )
        {
            $new = 'literal';
        }

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

        if ( blessed $attrs->{$key}
            && $attrs->{$key}->isa('HTML::FormFu::Literal') )
        {
            $orig = 'literal';
        }

        my $new = 'string';

        if ( blessed $value
            && $value->isa('HTML::FormFu::Literal') )
        {
            $new = 'literal';
        }

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

    if ( !@_ ) {
        return;
    }
    elsif ( @_ > 1 ) {
        return @_;
    }
    elsif ( ref $_[0] ) {
        return %{ $_[0] };
    }
    else {
        return ( name => $_[0] );
    }
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

        while ( my ( $key, $value ) = each %val ) {
            $val{$key} = xml_escape($value);
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

    croak 'argument to process_attrs() must be a hashref'
        if reftype( $attrs ) ne 'HASH';

    my @attribute_parts;

    for my $attribute ( sort keys %$attrs ) {
        my $value
            = defined $attrs->{$attribute}
            ? $attrs->{$attribute}
            : $EMPTY_STR;

        push @attribute_parts, sprintf '%s="%s"', $attribute, $value;
    }

    my $xml = join $SPACE, @attribute_parts;

    if ( length $xml ) {
        $xml = " $xml";
    }

    return $xml;
}

sub split_name {
    my ($name) = @_;

    croak "split_name requires 1 arg" if @_ != 1;

    return if !defined $name;

    if ( $name =~ /^ \w+ \[ /x ) {

        # copied from Catalyst::Plugin::Params::Nested::Expander
        # redistributed under the same terms as Perl

        return grep {defined} (
            $name =~ /
            ^  (\w+)      # root param
            | \[ (\w+) \] # nested
        /gx
        );
    }
    elsif ( $name =~ /\./ ) {

        # Copied from CGI::Expand
        # redistributed under the same terms as Perl

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

# sub _merge_hashes originally copied from Catalyst::Utils::merge_hashes()
# redistributed under the same terms as Perl

sub _merge_hashes {
    my ( $lefthash, $righthash ) = @_;

    return $lefthash if !defined $righthash || !keys %$righthash;

    my %merged = %$lefthash;

    while ( my ( $key, $value ) = each %$righthash ) {
        my $is_right_ref = ref $value eq 'HASH';
        my $is_left_ref = exists $lefthash->{$key} && ref $value eq 'HASH';

        if ( $is_left_ref && $is_right_ref ) {
            $merged{$key} = _merge_hashes( $lefthash->{$key}, $value );
        }
        else {
            $merged{$key} = $value;
        }
    }

    return \%merged;
}

1;
