package HTML::FormFu::Element;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors mk_inherited_accessors );
use HTML::FormFu::Attribute qw/ mk_attrs mk_attr_accessors /;
use HTML::FormFu::ObjectUtil qw/ load_config_file _render_class
    populate form stash /;
use HTML::FormFu::Util qw/ _parse_args require_class xml_escape /;
use Scalar::Util qw/ refaddr /;
use Storable qw( dclone );
use Carp qw/ croak /;

use overload
    '""' => sub { return shift->render },
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    bool => sub {1};

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_attr_accessors(qw/ id /);

__PACKAGE__->mk_accessors(qw/
    parent
    render_class_args name element_type render_class_prefix render_class_suffix
    filename render_class 
    multi_filename render_method is_field /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->attributes( {} );
    $self->stash( {} );

    $self->populate( \%attrs );

    return $self;
}

sub get_elements { [] }

sub get_element { }

sub get_all_elements { [] }

sub get_fields { [] }

sub get_field { }

sub get_constraints { [] }

sub get_constraint { }

sub get_filters { [] }

sub get_filter { }

sub get_deflators { [] }

sub get_deflator { }

sub get_inflators { [] }

sub get_inflator { }

sub get_errors { [] }

sub prepare { }

sub prepare_id { }

sub prepare_attrs { }

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    $new{render_class_args} = dclone $self->render_class_args;
    $new{attributes}        = dclone $self->attributes;
    
    return bless \%new, ref $self;
}


sub render {
    my $self = shift;

    my $class = $self->_render_class('Element');
    require_class($class);

    my $render = $class->new({
        name                => xml_escape( $self->name ),
        attributes          => xml_escape( $self->attributes ),
        render_class_args   => dclone( $self->render_class_args ),
        element_type        => $self->element_type,
        render_class_suffix => $self->render_class_suffix,
        render_method       => $self->render_method,
        filename            => $self->filename,
        multi_filename      => $self->multi_filename,
        is_field            => $self->is_field,
        stash               => $self->stash,
        parent              => $self,
        @_ ? %{$_[0]} : ()
        });
    
    $self->prepare_id($render);
    
    $self->prepare_attrs($render);
    
    return $render;
}

1;

__END__

=head1 NAME

HTML::Widget::Element - Element Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 Core Elements

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
