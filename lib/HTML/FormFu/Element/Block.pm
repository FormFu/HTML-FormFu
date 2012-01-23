package HTML::FormFu::Element::Block;
use Moose;
use MooseX::Attribute::Chained;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::CreateChildren',
     'HTML::FormFu::Role::GetProcessors',
     'HTML::FormFu::Role::ContainsElements',
     'HTML::FormFu::Role::ContainsElementsSharedWithField',
     'HTML::FormFu::Role::FormAndBlockMethods';

use HTML::FormFu::Constants qw( $EMPTY_STR );
use HTML::FormFu::Util qw( _get_elements xml_escape process_attrs );
use Clone ();
use List::MoreUtils qw( uniq );
use Carp qw( croak );

has tag                  => ( is => 'rw', traits => ['Chained'] );
has nested_name          => ( is => 'rw', traits => ['Chained'] );
has original_nested_name => ( is => 'rw', traits => ['Chained'] );
has auto_block_id        => ( is => 'rw', traits => ['Chained'] );

has _elements => (
    is      => 'rw',
    default => sub { [] },
    lazy    => 1,
    isa     => 'ArrayRef',
);

__PACKAGE__->mk_output_accessors(qw( content ));

__PACKAGE__->mk_inherited_accessors( qw(
        auto_id auto_label auto_error_class auto_error_message
        auto_constraint_class auto_inflator_class auto_validator_class
        auto_transformer_class render_processed_value force_errors
        repeatable_count
        locale
) );

*elements     = \&element;
*constraints  = \&constraint;
*deflators    = \&deflator;
*filters      = \&filter;
*inflators    = \&inflator;
*validators   = \&validator;
*transformers = \&transformer;
*plugins      = \&plugin;

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->filename( 'block' );
    $self->tag(      'div' );
    $self->is_block( 1 );
    
    return;
};

sub _single_plugin {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add plugin to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_plugin( $type, $arg );
            push @{ $field->_plugins }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub pre_process {
    my ($self) = @_;

    map { $_->pre_process } @{ $self->_elements };

    return;
}

sub process {
    my ($self) = @_;

    map { $_->process } @{ $self->_elements };

    return;
}

sub post_process {
    my ($self) = @_;

    map { $_->post_process } @{ $self->_elements };

    return;
}

sub render_data {
    my $self = shift;

    my $render = $self->render_data_non_recursive( { @_ ? %{ $_[0] } : () } );

    $render->{elements} = [ map { $_->render_data } @{ $self->_elements } ];

    return $render;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            tag     => $self->tag,
            content => xml_escape( $self->content ),
            $args ? %$args : (),
        } );

    return $render;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    if (  !defined $render->{attributes}{id}
        && defined $self->auto_block_id
        && length $self->auto_block_id )
    {
        my $form_name
            = defined $self->form->id
            ? $self->form->id
            : $EMPTY_STR;

        my %string = (
            f => $form_name,
        );

        my $id = $self->auto_block_id;
        $id =~ s/%([f])/$string{$1}/g;

        if ( defined( my $count = $self->repeatable_count ) ) {
            $id =~ s/%r/$count/g;
        }

        $render->{attributes}{id} = $id;
    }

    return;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data_non_recursive;

    # start_block template

    my $html = '';

    if ( defined $render->{tag} ) {
        $html .= sprintf "<%s%s>",
            $render->{tag},
            process_attrs( $render->{attributes} ),
            ;
    }

    if ( defined $render->{legend} ) {
        $html .= sprintf "\n<legend>%s</legend>", $render->{legend};
    }

    # block template

    $html .= "\n";

    if ( defined $render->{content} ) {
        $html .= sprintf "%s\n", $render->{content};
    }
    else {
        for my $elem ( @{ $self->get_elements } ) {

            # call render, so that child elements can use a different renderer
            my $elem_html = $elem->render;

            # skip Blank fields
            if ( length $elem_html ) {
                $html .= $elem_html . "\n";
            }
        }
    }

    # end_block template

    if ( defined $render->{tag} ) {
        $html .= sprintf "</%s>", $render->{tag};
    }

    return $html;
}

sub start {
    my ($self) = @_;

    return $self->tt( {
            filename    => 'start_block',
            render_data => $self->render_data_non_recursive,
        } );
}

sub end {
    my ($self) = @_;

    return $self->tt( {
            filename    => 'end_block',
            render_data => $self->render_data_non_recursive,
        } );
}

sub clone {
    my $self = shift;

    my $clone = $self->SUPER::clone(@_);

    $clone->_elements( [ map { $_->clone } @{ $self->_elements } ] );

    map { $_->parent($clone) } @{ $clone->_elements };

    $clone->default_args( Clone::clone( $self->default_args ) );

    return $clone;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Block - Block element

=head1 SYNOPSIS

    ---
    elements: 
      - type: Block
        elements: 
          - type: Text
            name: foo
    
      - type: Block
        tag: span
        content: Whatever

=head1 DESCRIPTION

Block element which may contain other elements.

=head1 METHODS

=head2 tag

Specifies which tag name should be used to render the block.

Default Value: 'div'

=head2 content

If L</content> is set, it is used as the block's contents, and any attached 
elements are ignored.

=head2 content_xml

Arguments: $string

If you don't want the content to be XML-escaped, use the L</content_xml> 
method instead of L</content>.

=head2 content_loc

Arguments: $localization_key

To set the content to a localized string, set L</content_loc> to a key in 
your L10N file instead of using L</content>.

=head2 elements

See L<HTML::FormFu/elements> for details.

=head2 element

See L<HTML::FormFu/element> for details.

=head2 deflators

See L<HTML::FormFu/deflators> for details.

=head2 deflator

See L<HTML::FormFu/deflator> for details.

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

=head2 auto_block_id

Arguments: [$string]

If set, the Block will be given an auto-generated
L<id|HTML::FormFu::Element/id> attribute, if it doesn't have one already.

The following character substitution will be performed: C<%f> will be
replaced by L<< $form->id|/id >>, C<%r> will be replaced by
L<< $block->repeatable_count|HTML::FormFu::Element::Repeatable/repeatable_count >>.

Default Value: not defined

Unlike most other auto_* methods, this is not an 'inherited accessor'.

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

=head2 default_args

See L<HTML::FormFu/default_args> for details.

=head1 RENDERING

=head2 start

=head2 end

=head1 INTROSPECTION

=head2 get_elements

See L<HTML::FormFu/get_elements> for details.

=head2 get_element

See L<HTML::FormFu/get_element> for details.

=head2 get_all_elements

See L<HTML::FormFu/get_all_elements> for details.

=head2 get_fields

See L<HTML::FormFu/get_fields> for details.

=head2 get_field

See L<HTML::FormFu/get_field> for details.

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

Base-class for L<HTML::FormFu::Element::Fieldset>.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 REMOVED METHODS

=head2 element_defaults

Has been removed; use L</default_args> instead.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
