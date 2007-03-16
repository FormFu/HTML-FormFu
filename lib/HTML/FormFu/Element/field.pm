package HTML::FormFu::Element::field;

use strict;
use warnings;
use base 'HTML::FormFu::Element';

use HTML::FormFu::Attribute qw/ mk_attrs /;
use HTML::FormFu::ObjectUtil 
    qw/  get_constraint get_filter get_deflator get_inflator get_validator 
    get_error
    _require_constraint _require_filter _require_inflator _require_deflator
    _require_validator /;
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
    _constraints _filters _inflators _deflators _validators _errors
    field_filename label_filename errors retain_default javascript /);

__PACKAGE__->mk_output_accessors(qw/ comment label value /);

__PACKAGE__->mk_inherited_accessors(
    qw/ auto_id auto_label auto_error_class auto_error_message
    auto_constraint_class auto_validator_class /
);

# build _single_X methods

for my $method (qw/ deflator filter constraint inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my ( $self, $arg ) = @_;
        my @items;
    
        if ( ref $arg eq 'HASH' ) {
            push @items, $arg;
        }
        elsif ( !ref $arg ) {
            push @items, { type => $arg };
        }
        else {
            croak 'invalid args';
        }
    
        my @return;
    
        for my $item (@items) {
            my $type = delete $item->{type};
            my $require_method = "_require_$method";
            my $array_method = "_${method}s";
            
            my $new = $self->$require_method( $type, $item );
            
            push @{ $self->$array_method }, $new;
            push @return, $new;
        }
    
        return @return;
        };
    
    my $name = __PACKAGE__ . "::_single_$method";
    
    *{$name} = $sub;
}

# build get_Xs methods

for my $method (qw/ deflator filter constraint inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my $self = shift;
        my %args = _parse_args(@_);
        my $array_method = "_${method}s";
        
        my @x = @{ $self->$array_method };
    
        if ( exists $args{name} ) {
            @x = grep { $_->name eq $args{name} } @x;
        }
    
        if ( exists $args{type} ) {
            my $type_method = "${method}_type";
            
            @x = grep { $_->$type_method eq $args{type} } @x;
        }
    
        return \@x;
        };
    
    my $name = __PACKAGE__ . "::get_${method}s";
        
    *{$name} = $sub;
}

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
    $self->_validators(  [] );
    $self->_errors(      [] );
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

sub validator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_validator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_validator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = @{ $self->_errors };

    if ( exists $args{name} ) {
        @e = grep { $_->name eq $args{name} } @e;
    }

    if ( exists $args{type} ) {
        @e = grep { $_->type eq $args{type} } @e;
    }
    
    if ( exists $args{stage} ) {
        @e = grep { $_->stage eq $args{stage} } @e;
    }

    return \@e;
}

sub add_error {
    my ( $self, @errors ) = @_;
    
    push @{ $self->_errors }, @errors;
    
    return;
}

sub delete_errors {
    my ($self) = @_;
    
    $self->_errors([]);
    
    return;
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

    $self->_render_container_class($render);
    
    $self->_render_comment_class($render);
    
    $self->_render_label($render);

    $self->_render_value($render);
    
    $self->_render_constraint_class($render);
    
#    $self->_render_inflator_class($render);
    
    $self->_render_validator_class($render);

    $self->_render_error_class($render);

    return $render;
}

sub _render_label {
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

        $render->{label} = $self->form->localize( $label );
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
    
    return;
}

sub _render_comment_class {
    my ( $self, $render ) = @_;
    
    if ( defined $render->{comment} ) {
        append_xml_attribute( $render->{comment_attributes}, 'class', 'comment' );
        append_xml_attribute( $render->{container_attributes},
            'class', 'comment' );
    }
    
    return;
}

sub _render_value {
    my ( $self, $render ) = @_;
    
    my $input = exists $self->form->input->{ $self->name } 
              ? $self->form->input->{ $self->name } 
              : undef;
              
    my $value = $self->process_value($input);
    
    if ( !$self->form->submitted ) {
        for my $deflator ( @{ $self->_deflators } ) {
            $value = $deflator->process($value);
        }
    }
    
    if ( ref $value eq 'ARRAY' && defined $self->name ) {
        my $max = $#$value;
        my $fields = $self->form->get_fields( name => $self->name );
        
        for (0..$max) {
            if ( defined $fields->[$_] && $fields->[$_] eq $self ) {
                $value = $value->[$_];
                last;
            }
        }
    }
    
    $render->{value} = xml_escape $value;
    
    return;
}

sub _render_container_class {
    my ( $self, $render ) = @_;
    
    my $type = $self->element_type;
    $type =~ s/:://g;

    append_xml_attribute( $render->{container_attributes},
        'class', lc($type) );
    
    return;
}

sub _render_constraint_class {
    my ( $self, $render ) = @_;
    
    my $auto_class = $self->auto_constraint_class;
    
    return if !defined $auto_class;
    
    for my $c ( @{ $self->_constraints } ) {
        my %string = (
            f => defined $self->form->id     ? $self->form->id           : '',
            n => defined $render->{name}     ? $render->{name}           : '',
            t => defined $c->constraint_type ? lc( $c->constraint_type ) : '',
        );
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/ge;
        
        append_xml_attribute( $render->{container_attributes},
            'class', $class );
    }
    
    return;
}

sub _render_validator_class {
    my ( $self, $render ) = @_;
    
    my $auto_class = $self->auto_validator_class;
    
    return if !defined $auto_class;
    
    for my $c ( @{ $self->_validators } ) {
        my %string = (
            f => defined $self->form->id    ? $self->form->id           : '',
            n => defined $render->{name}    ? $render->{name}           : '',
            t => defined $c->validator_type ? lc( $c->validator_type ) : '',
        );
        
        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/ge;
        
        append_xml_attribute( $render->{container_attributes},
            'class', $class );
    }
    
    return;
}

sub _render_error_class {
    my ( $self, $render ) = @_;
    
    my @errors = @{ $self->get_errors };
    
    if (@errors) {
        $render->{errors} = \@errors;

        append_xml_attribute( $render->{container_attributes}, 'class', 'error' );

        for my $error (@errors) {
            append_xml_attribute( $render->{container_attributes},
                'class', $error->class );
        }
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
