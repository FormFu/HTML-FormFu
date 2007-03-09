package HTML::FormFu::Element::field;

use strict;
use warnings;
use base 'HTML::FormFu::Element';

use HTML::FormFu::Attribute qw/ mk_attrs /;
use HTML::FormFu::ObjectUtil 
    qw/  get_constraint get_filter get_deflator get_inflator
    _require_constraint _require_filter _require_inflator _require_deflator /;
use HTML::FormFu::Util qw/ _parse_args append_xml_attribute xml_escape require_class /;
use Storable qw/ dclone /;
use Carp qw/ croak /;

__PACKAGE__->mk_attrs(
    qw/
        comment_attributes
        container_attributes
        label_attributes
        /
);

__PACKAGE__->mk_accessors(qw/ 
    _constraints _filters _inflators _deflators
    field_filename label_filename errors retain_default javascript /);

__PACKAGE__->mk_output_accessors(qw/ comment label value /);

__PACKAGE__->mk_inherited_accessors(qw/ auto_id auto_label /);

*constraints = \&constraint;
*filters     = \&filter;
*deflators   = \&deflator;
*inflators   = \&inflator;
*default     = \&value;
*default_xml = \&value_xml;
*default_loc = \&value_loc;
*value_loc   = \&value_loc;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_constraints( [] );
    $self->_filters(     [] );
    $self->_deflators(   [] );
    $self->_inflators(   [] );
    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->label_attributes(     {} );
    $self->label_filename('label');
    $self->is_field(1);
    $self->render_class_suffix('field');

    return $self;
}

sub constraint {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_constraint( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_constraint( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_constraint {
    my ( $self, $constraint ) = @_;
    my @constraints;

    if ( ref $constraint eq 'HASH' ) {
        push @constraints, $constraint;
    }
    elsif ( !ref $constraint ) {
        push @constraints, { type => $constraint };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $c (@constraints) {
        my $type = delete $c->{type};
        
        my $new = $self->_require_constraint( $type, $c );
        
        push @{ $self->_constraints }, $new;
        push @return, $new;
    }

    return @return;
}

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @c = @{ $self->_constraints };

    if ( exists $args{name} ) {
        @c = grep { $_->name eq $args{name} } @c;
    }

    if ( exists $args{type} ) {
        @c = grep { $_->constraint_type eq $args{type} } @c;
    }

    return \@c;
}

sub filter {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_filter( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_filter( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_filter {
    my ( $self, $filter ) = @_;
    my @filters;

    if ( ref $filter eq 'HASH' ) {
        push @filters, $filter;
    }
    elsif ( !ref $filter ) {
        push @filters, { type => $filter };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $f (@filters) {
        my $type = delete $f->{type};
        
        my $new = $self->_require_filter( $type, $f );
        
        push @{ $self->_filters }, $new;
        push @return, $new;
    }

    return @return;
}

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @f = @{ $self->_filters };

    if ( exists $args{name} ) {
        @f = grep { $_->name eq $args{name} } @f;
    }

    if ( exists $args{type} ) {
        @f = grep { $_->filter_type eq $args{type} } @f;
    }

    return \@f;
}

sub deflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_deflator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_deflator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_deflator {
    my ( $self, $deflator ) = @_;
    my @deflators;

    if ( ref $deflator eq 'HASH' ) {
        push @deflators, $deflator;
    }
    elsif ( !ref $deflator ) {
        push @deflators, { type => $deflator };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $f (@deflators) {
        my $type = delete $f->{type};
        
        my $new = $self->_require_deflator( $type, $f );
        
        push @{ $self->_deflators }, $new;
        push @return, $new;
    }

    return @return;
}

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @d = @{ $self->_deflators };

    if ( exists $args{name} ) {
        @d = grep { $_->name eq $args{name} } @d;
    }

    if ( exists $args{type} ) {
        @d = grep { $_->deflator_type eq $args{type} } @d;
    }

    return \@d;
}

sub inflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_inflator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_inflator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_inflator {
    my ( $self, $inflator ) = @_;
    my @inflators;

    if ( ref $inflator eq 'HASH' ) {
        push @inflators, $inflator;
    }
    elsif ( !ref $inflator ) {
        push @inflators, { type => $inflator };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $i (@inflators) {
        my $type = delete $i->{type};
        
        my $new = $self->_require_inflator( $type, $i );
        
        push @{ $self->_inflators }, $new;
        push @return, $new;
    }

    return @return;
}

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @i = @{ $self->_inflators };

    if ( exists $args{name} ) {
        @i = grep { $_->name eq $args{name} } @i;
    }

    if ( exists $args{type} ) {
        @i = grep { $_->inflator_type eq $args{type} } @i;
    }

    return \@i;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    if ( !defined $render->{attributes}{id}
         && defined $self->auto_id
         && length $self->auto_id )
    {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
        );

        my $id = $self->auto_id;
        $id =~ s/%([fn])/$string{$1}/ge;

        $render->{attributes}{id} = $id;
    }

    return;
}

sub process_value {
    my ( $self, $value ) = @_;
    
    my $submitted = $self->form->submitted;
    my $default   = $self->default;

    my $new = $submitted 
            ? defined $value 
                ? $value 
                : defined $default 
                    ? "" 
                    : undef 
            : $default;

    if ( $submitted && $self->retain_default && defined $new && $new eq "" ) {
        $new = $default;
    }

    return $new;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        comment_attributes   => xml_escape( $self->comment_attributes ),
        container_attributes => xml_escape( $self->container_attributes ),
        label_attributes     => xml_escape( $self->label_attributes ),
        comment              => xml_escape( $self->comment ),
        label                => xml_escape( $self->label ),
        field_filename       => $self->field_filename,
        label_filename       => $self->label_filename,
        javascript           => $self->javascript,
        @_ ? %{$_[0]} : ()
        });

    $self->_render_auto_label($render);

    my $input = exists $self->form->input->{ $self->name } 
              ? $self->form->input->{ $self->name } 
              : undef;
              
    my $value = $self->process_value($input);
    
    for my $deflator ( @{ $self->_deflators } ) {
        $value = $deflator->process($value);
    }
    $render->{value} = xml_escape $value;
    
    {
        my $type = $self->element_type;
        $type =~ s/:://g;

        append_xml_attribute( $render->{container_attributes},
            'class', lc($type), );
    }

    my $errors = $self->form->errors( defined $self->name ? $self->name : () );
    
    if ($errors) {
        $render->{errors} = $errors;

        append_xml_attribute( $render->{container_attributes}, 'class', 'error' );

        for my $error (@$errors) {
            append_xml_attribute( $render->{container_attributes},
                'class', $error->class );
        }
    }

    if ( defined $render->{comment} ) {
        append_xml_attribute( $render->{comment_attributes}, 'class', 'comment' );
        append_xml_attribute( $render->{container_attributes},
            'class', 'comment' );
    }

    if ( defined $render->{label} ) {
        append_xml_attribute( $render->{container_attributes}, 'class', 'label' );
    }
    
    # label "for" attribute
    if (   defined $render->{label}
        && defined $render->{attributes}{id}
        && !exists $render->{label_attributes}{for} )
    {
        $render->{label_attributes}{for} = $render->{attributes}{id};
    }

    return $render;
}

sub _render_auto_label {
    my ( $self, $render ) = @_;
    
    if ( !defined $render->{label}
         && defined $self->auto_label
         && length $self->auto_label )
    {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
        );

        my $label = $self->auto_label;
        $label =~ s/%([fn])/$string{$1}/ge;

        $render->{label} = $self->localize( $label );
    }
    
    return;
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    for my $list (qw/ _constraints _filters _inflators _deflators /) {
        $clone->{$list} = [ map { $_->clone } @{ $self->$list } ];
    }
    
    $clone->{comment_attributes}   = dclone $self->comment_attributes;
    $clone->{container_attributes} = dclone $self->container_attributes;
    $clone->{label_attributes}     = dclone $self->label_attributes;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::field - form field base-class.

=head1 DESCRIPTION

Form field base-class.

Base-class for L<HTML::FormFu::Element::group>, L<HTML::FormFu::Element::input>,
L<HTML::FormFu::Element::Multi>, L<HTML::FormFu::Element::ContentButton>, 
L<HTML::FormFu::Element::Textarea>.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
