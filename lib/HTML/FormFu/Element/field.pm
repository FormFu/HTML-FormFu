package HTML::FormFu::Element::field;

use strict;
use warnings;
use base 'HTML::FormFu::Element';

use HTML::FormFu::Attribute qw/ 
    mk_attrs mk_require_methods mk_get_one_methods /;
use HTML::FormFu::ObjectUtil qw/   
    get_error _require_constraint /;
use HTML::FormFu::Util qw/ 
    _parse_args append_xml_attribute xml_escape require_class /;
use Storable qw/ dclone /;
use Carp qw/ croak /;
use Exporter qw/ import /;

# used by multi.pm
our @EXPORT_OK = qw/
    _render_container_class _render_comment_class _render_label /;

__PACKAGE__->mk_attrs(
    qw/
        comment_attributes
        container_attributes
        label_attributes
        /
);

__PACKAGE__->mk_accessors(qw/ 
    _constraints _filters _inflators _deflators _validators _transformers 
    _errors container_tag
    field_filename label_filename retain_default javascript /);

__PACKAGE__->mk_output_accessors(qw/ comment label value /);

__PACKAGE__->mk_inherited_accessors(
    qw/ auto_id auto_label auto_error_class auto_error_message
    auto_constraint_class auto_inflator_class auto_validator_class 
    auto_transformer_class render_processed_value force_errors /);

__PACKAGE__->mk_require_methods(qw/ 
    deflator filter inflator validator transformer /);

__PACKAGE__->mk_get_one_methods(qw/ 
    deflator filter constraint inflator validator transformer /);

# build _single_X methods

for my $method (qw/ 
    deflator filter constraint inflator validator transformer /)
{
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

for my $method (qw/ 
    deflator filter constraint inflator validator transformer /)
{
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
            @x = grep { $_->type eq $args{type} } @x;
        }
    
        return \@x;
        };
    
    my $name = __PACKAGE__ . "::get_${method}s";
        
    *{$name} = $sub;
}

*constraints  = \&constraint;
*filters      = \&filter;
*deflators    = \&deflator;
*inflators    = \&inflator;
*validators   = \&validator;
*transformers = \&transformer;
*default      = \&value;
*default_xml  = \&value_xml;
*default_loc  = \&value_loc;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_constraints(  [] );
    $self->_filters(      [] );
    $self->_deflators(    [] );
    $self->_inflators(    [] );
    $self->_validators(   [] );
    $self->_transformers( [] );
    $self->_errors(       [] );
    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->label_attributes(     {} );
    $self->label_filename('label');
    $self->container_tag('span');
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

sub transformer {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_transformer( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_transformer( $self, $arg );
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
    
    if ( !$args{forced} ) {
        @e = grep { !$_->forced } @e;
    }

    return \@e;
}

sub add_error {
    my ( $self, @errors ) = @_;
    
    push @{ $self->_errors }, @errors;
    
    return;
}

sub clear_errors {
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
        $id =~ s/%([fn])/$string{$1}/g;

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
        container_tag        => $self->container_tag,
        javascript           => $self->javascript,
        @_ ? %{$_[0]} : ()
        });

    $self->_render_container_class($render);
    
    $self->_render_comment_class($render);
    
    $self->_render_label($render);

    $self->_render_value($render);
    
    $self->_render_constraint_class($render);
    
    $self->_render_inflator_class($render);
    
    $self->_render_validator_class($render);
    
    $self->_render_transformer_class($render);

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
        $label =~ s/%([fn])/$string{$1}/g;

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
    
    my $render_processed;
    
    my $input = ( $self->form->submitted
                 && defined $self->name 
                 && exists $self->form->input->{ $self->name } ) 
              ? $self->render_processed_value 
                ? ( $render_processed = 1 && 
                    $self->form->_processed_params->{ $self->name } 
                  )
                : $self->form->input->{ $self->name } 
              : undef;
    
    if ( ref $input eq 'ARRAY' ) {
        my $elems = $self->form->get_fields( $self->name );
        for ( 0 .. @$elems-1 ) {
            if ( $self == $elems->[$_] ) {
                $input = $input->[$_];
            }
        }
    }
    
    my $value = $self->process_value($input);
    
    if ( !$self->form->submitted || $render_processed ) {
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
    
    my $type = $self->type;
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
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/g;
        
        append_xml_attribute( $render->{container_attributes},
            'class', $class );
    }
    
    return;
}

sub _render_inflator_class {
    my ( $self, $render ) = @_;
    
    my $auto_class = $self->auto_inflator_class;
    
    return if !defined $auto_class;
    
    for my $c ( @{ $self->_inflators } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );
        
        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/g;
        
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
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );
        
        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/g;
        
        append_xml_attribute( $render->{container_attributes},
            'class', $class );
    }
    
    return;
}

sub _render_transformer_class {
    my ( $self, $render ) = @_;
    
    my $auto_class = $self->auto_transformer_class;
    
    return if !defined $auto_class;
    
    for my $c ( @{ $self->_transformers } ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id : '',
            n => defined $render->{name} ? $render->{name} : '',
            t => defined $c->type        ? lc( $c->type )  : '',
        );
        
        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;
        
        my $class = $auto_class;
        
        $class =~ s/%([fnt])/$string{$1}/g;
        
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
    
    for my $list (qw/ _filters _constraints _inflators _validators _transformers 
                     _deflators /)
    {
        $clone->$list( [ map { $_->clone } @{ $self->$list } ] );
    }
    
    $clone->comment_attributes(   dclone $self->comment_attributes );
    $clone->container_attributes( dclone $self->container_attributes );
    $clone->label_attributes(     dclone $self->label_attributes );
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::field

=head1 DESCRIPTION

Base-class for all form-field elements.

=head1 METHODS

=head2 default

Set the form-field's default value.

=head2 default_xml

Arguments: $string

If you don't want the default value to be XML-escaped, use the 
L</default_xml> method instead of </default>.

=head2 default_loc

Arguments: $localization_key

Set the default value using a L10N key.

=head2 value

For most fields, L</value> is an alias for L</default>.

For the L<HTML::FormFu::Element::checkbox> and 
L<HTML::FormFu::Element::radio> elements, L</value> sets what the value of 
the field will be if it is checked or selected. If the L</default> is the 
same as the L</value>, then the field will be checked or selected when 
rendered.

For the L<HTML::FormFu::Element::radiogroup> and 
L<HTML::FormFu::Element::select> elements, the L</value> is ignored: 
L</values|HTML::FormFu::Element::group/values> or 
L</options|HTML::FormFu::Element::group/options> provides the equivalent 
function.

=head2 value_xml

Arguments: $string

If you don't want the value to be XML-escaped, use the L</value_xml> 
method instead of </value>.

=head2 value_loc

Arguments: $localization_key

Set the value using a L10N key.

=head2 label

Set a label to communicate the purpose of the form-field to the user.

=head2 label_xml

Arguments: $string

If you don't want the label to be XML-escaped, use the L</label_xml> 
method instead of </label>.

=head2 label_loc

Arguments: $localization_key

Set the label using a L10N key.

=head2 comment

Set a comment to be displayed along with the form-field.

=head2 comment_xml

Arguments: $string

If you don't want the comment to be XML-escaped, use the L</comment_xml> 
method instead of </comment>.

=head2 comment_loc

Arguments: $localization_key

Set the comment using a L10N key.

=head2 container_tag

Set which tag-name should be used to contain the various field parts (field, 
label, comment, errors, etc.).

Default Value: 'span'

=head2 javascript

Arguments: [$javascript]

If set, the contents will be rendered within a C<script> tag, within the 
field's container.

=head2 retain_default

If L</retain_default> is true and the form was submitted, but the field 
didn't have a value submitted, then when the form is redisplayed to the user 
the field will have it's value set to it's default value , rather than the 
usual behaviour of having an empty value.

Default Value: C<false>

=head2 render_processed_value

The default behaviour when re-displaying a form after a submission, is that 
the field contains the original unchanged user-submitted value.

If L</render_processed_value> is true, the field value will be the final 
result after all Filters, Inflators and Transformers have been run. 
Deflators will also be run on the value.

Default Value: false

=head2 clone

See L<HTML::FormFu/clone> for details.

=head2 deflators

See L<HTML::FormFu/deflators> for details.

=head2 deflator

See L<HTML::FormFu/deflator> for details.

=head1 ATTRIBUTES

=head2 comment_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Attributes added to the comment container.

=head2 comment_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</comment_attributes_xml> method instead of </comment_attributes>.

=head2 add_comment_attributes

=head2 add_comment_attrs

See L<HTML::FormFu::/add_attributes> for details.

=head2 add_comment_attributes_xml

=head2 add_comment_attrs_xml

See L<HTML::FormFu::/add_attributes_xml> for details.

=head2 add_comment_attributes_loc

=head2 add_comment_attrs_loc

See L<HTML::FormFu::/add_attributes_loc> for details.

=head2 del_comment_attributes

=head2 del_comment_attrs

See L<HTML::FormFu::/del_attributes> for details.

=head2 del_comment_attributes_xml

=head2 del_comment_attrs_xml

See L<HTML::FormFu::/del_attributes_xml> for details.

=head2 del_comment_attributes_loc

=head2 del_comment_attrs_loc

See L<HTML::FormFu::/del_attributes_loc> for details.

=head2 container_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Arguments added to the field's container.

=head2 container_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</container_attributes_xml> method instead of </container_attributes>.

=head2 add_container_attributes

=head2 add_container_attrs

See L<HTML::FormFu::/add_attributes> for details.

=head2 add_container_attributes_xml

=head2 add_container_attrs_xml

See L<HTML::FormFu::/add_attributes_xml> for details.

=head2 add_container_attributes_loc

=head2 add_container_attrs_loc

See L<HTML::FormFu::/add_attributes_loc> for details.

=head2 del_container_attributes

=head2 del_container_attrs

See L<HTML::FormFu::/del_attributes> for details.

=head2 del_container_attributes_xml

=head2 del_container_attrs_xml

See L<HTML::FormFu::/del_attributes_xml> for details.

=head2 del_container_attributes_loc

=head2 del_container_attrs_loc

See L<HTML::FormFu::/del_attributes_loc> for details.

=head2 label_attributes

Arguments: [%attributes]

Arguments: [\%attributes]

Attributes added to the label container.

=head2 label_attributes_xml

Arguments: [%attributes]

Arguments: [\%attributes]

If you don't want the values to be XML-escaped, use the 
L</label_attributes_xml> method instead of </label_attributes>.

=head2 add_label_attributes

=head2 add_label_attrs

See L<HTML::FormFu::/add_attributes> for details.

=head2 add_label_attributes_xml

=head2 add_label_attrs_xml

See L<HTML::FormFu::/add_attributes_xml> for details.

=head2 add_label_attributes_loc

=head2 add_label_attrs_loc

See L<HTML::FormFu::/add_attributes_loc> for details.

=head2 del_label_attributes

=head2 del_label_attrs

See L<HTML::FormFu::/del_attributes> for details.

=head2 del_label_attributes_xml

=head2 del_label_attrs_xml

See L<HTML::FormFu::/del_attributes_xml> for details.

=head2 del_label_attributes_loc

=head2 del_label_attrs_loc

See L<HTML::FormFu::/del_attributes_loc> for details.

=head1 FORM LOGIC AND VALIDATION

=head2 filters

See L<HTML::FormFu/filters> for details.

=head2 filter

See L<HTML::FormFu/filter> for details.

=head2 constraints

See L<HTML::FormFu/constraints> for details.

=head2 constraint

See L<HTML::FormFu/constraint> for details.

=head2 inflators

See L<HTML::FormFu/inflators> for details.

=head2 inflator

See L<HTML::FormFu/inflator> for details.

=head2 validators

See L<HTML::FormFu/validators> for details.

=head2 validator

See L<HTML::FormFu/validator> for details.

=head2 transformers

See L<HTML::FormFu/transformers> for details.

=head2 transformer

See L<HTML::FormFu/transformer> for details.

=head1 CSS CLASSES

=head2 auto_id

See L<HTML::FormFu/auto_id> for details.

=head2 auto_label

See L<HTML::FormFu/auto_label> for details.

=head2 auto_error_class

See L<HTML::FormFu/auto_error_class> for details.

=head2 auto_error_message

See L<HTML::FormFu/auto_error_message> for details.

=head2 auto_constraint_class

See L<HTML::FormFu/auto_constraint_class> for details.

=head2 auto_inflator_class

See L<HTML::FormFu/auto_inflator_class> for details.

=head2 auto_validator_class

See L<HTML::FormFu/auto_validator_class> for details.

=head2 auto_transformer_class

See L<HTML::FormFu/auto_transformer_class> for details.

=head1 RENDERING

=head2 field_filename

The template filename to be used for just the form field - not including the 
display of any container, label, errors, etc. 

Must be set by more specific field classes.

=head2 label_filename

The template filename to be used to render the label.

Must be set by more specific field classes.

=head1 ERROR HANDLING

=head2 get_errors

See L<HTML::FormFu/get_errors> for details.

=head2 add_error

=head2 clear_errors

See L<HTML::FormFu/clear_errors> for details.

=head1 INTROSPECTION

=head2 get_deflators

See L<HTML::FormFu/get_deflators> for details.

=head2 get_deflator

See L<HTML::FormFu/get_deflator> for details.

=head2 get_filters

See L<HTML::FormFu/get_filters> for details.

=head2 get_filter

See L<HTML::FormFu/get_filter> for details.

=head2 get_constraints

See L<HTML::FormFu/get_constraints> for details.

=head2 get_constraint

See L<HTML::FormFu/get_constraint> for details.

=head2 get_inflators

See L<HTML::FormFu/get_inflators> for details.

=head2 get_inflator

See L<HTML::FormFu/get_inflator> for details.

=head2 get_validators

See L<HTML::FormFu/get_validators> for details.

=head2 get_validator

See L<HTML::FormFu/get_validator> for details.

=head2 get_transformers

See L<HTML::FormFu/get_transformers> for details.

=head2 get_transformer

See L<HTML::FormFu/get_transformer> for details.

=head2 get_errors

See L<HTML::FormFu/get_errors> for details.

=head2 clear_errors

See L<HTML::FormFu/clear_errors> for details.

=head1 SEE ALSO

Base-class for L<HTML::FormFu::Element::group>, L<HTML::FormFu::Element::input>,
L<HTML::FormFu::Element::Multi>, L<HTML::FormFu::Element::ContentButton>, 
L<HTML::FormFu::Element::Textarea>.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
