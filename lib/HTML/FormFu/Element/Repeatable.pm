package HTML::FormFu::Element::Repeatable;

use strict;
use base 'HTML::FormFu::Element::Block';
use Class::C3;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(
    qw/ _original_elements increment_field_names counter_name /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('repeatable');
    $self->is_repeatable(1);
    $self->increment_field_names(1);

    return $self;
}

sub repeat {
    my ( $self, $count ) = @_;

    $count ||= 1;

    croak "invalid number to repeat"
        unless $count =~ /^[1-9][0-9]*\z/;

    my $children;

    if ( $self->_original_elements ) {

        # repeat() has already been called
        $children = $self->_original_elements;
    }
    else {
        $children = $self->_elements;
        $self->_original_elements($children);
    }

    croak "no child elements to repeat"
        if !@$children;

    $self->_elements( [] );

    my @return;

    for my $rep ( 1 .. $count ) {
        my @clones = map { $_->clone } @$children;
        my $block = $self->element('Block');

        $block->_elements( \@clones );
        $block->attributes( $self->attributes );
        $block->tag( $self->tag );

        $block->repeatable_count($rep);

        if ( $self->increment_field_names ) {
            for my $field ( @{ $block->get_fields } ) {

                if ( defined( my $name = $field->name ) ) {
                    $field->original_name($name);

                    $name .= "_$rep";
                    $field->name($name);
                }
            }
        }

        _reparent_children($block);

        for my $field ( @{ $block->get_fields } ) {
            map { $_->parent($field) }
                @{ $field->_deflators },
                @{ $field->_filters },
                @{ $field->_constraints },
                @{ $field->_inflators },
                @{ $field->_validators },
                @{ $field->_transformers };
        }

        my $block_fields = $block->get_fields;

        my @others_constraints = grep { $_->can('others') }
            map { @{ $_->_constraints } } @$block_fields;

        for my $constraint (@others_constraints) {
            my $others = $constraint->others;
            $others = [$others] if !ref $others;
            my @new_others;

            for my $name (@$others) {
                my ($field)
                    = grep { $_->original_name eq $name } @$block_fields;

                if ( defined $field ) {
                    push @new_others, $field->nested_name;
                }
                else {
                    push @new_others, $name;
                }
            }

            $constraint->others( \@new_others );
        }

        push @return, $block;

    }

    return \@return;
}

sub _reparent_children {
    my $self = shift;

    return if $self->is_field;

    for my $child ( @{ $self->get_elements } ) {
        $child->parent($self);

        _reparent_children($child);
    }
}

sub process {
    my $self = shift;

    my $form  = $self->form;
    my $count = 1;

    if ( defined $self->counter_name && defined $form->query ) {
        my $input = $form->query->param( $self->counter_name );

        $count = $input
            if defined $input && $input =~ /^[1-9][0-9]*\z/;
    }

    $self->repeat($count);

    return $self->next::method(@_);
}

sub content {
    my $self = shift;

    croak "Repeatable elements do not support the content() method"
        if @_;

    return;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data_non_recursive;

    # block template

    my @divs = map { $_->render } @{ $self->get_elements };

    my $html = join "\n", @divs;

    return $html;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Repeatable - repeatable block element

=head1 SYNOPSIS

    ---
    elements:
      - type: Repeatable
        elements:
          - name: foo
          - name: bar

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="foo" type="text" />
        <input name="bar" type="text" />
    </div>
    <div>
        <input name="foo" type="text" />
        <input name="bar" type="text" />
    </div>

=head1 DESCRIPTION

Provides a way to extend a form at run-time, by copying and repeating it's 
child elements.

The elements intended for copying must be added before L</repeat> is called.

Although the Repeatable element inherits from 
L<Block|HTML::FormFu::Element::Block>, it doesn't generate a block tag 
around all the repeated elements - instead it places each repeat of the 
elements in a new L<Block|HTML::FormFu::Element::Block> element, which 
inherits the Repeatable's display settings, such as L</attributes> and 
L</tag>.

=head1 METHODS

=head2 repeat

Arguments: [$count]

Return Value: $arrayref_of_new_child_blocks

This method creates C<$count> number of copies of the child elements.
If no argument C<$count> is provided, it defaults to C<1>.

L</repeat> is automatically called during C<< $form->process >>, to ensure 
the initial child elements are correctly setup.

Any subsequent call to L</repeat> will delete the previously copied elements 
before creating new copies - this means you cannot make repeated calls to 
L</repeat> within a loop to create more copies.

Each copy of the elements returned are contained in a new 
L<Block|HTML::FormFu::Element::Block> element. For example, calling 
C<< $element->repeat(2) >> on a Repeatable element containing 2 Text fields 
would return 2 L<Block|HTML::FormFu::Element::Block> elements, each 
containing a copy of the 2 Text fields.

=head2 counter_name

Arguments: $name

If true, the L<HTML::FormFu/query> will be searched during 
L<HTML::FormFu/process> for a parameter with the given name. The value for 
that parameter will be passed to L</repeat>, to automatically create the 
new copies.

If L</increment_field_names> is true (the default), this is essential: if the
elements corresponding to the new fieldnames (foo_1, bar_2, etc.) are not 
present on the form during L<HTML::FormFu/process>, no Processors 
(Constraints, etc.) will be run on the fields, and their values will not 
be returned by L<HTML::FormFu/params> or L<HTML::FormFu/param>.

=head2 increment_field_names

Arguments: $bool

Default Value: 1

If true, then any copies of fields whose name contains a C<0>, will have 
the C<0> replaced by it's L</repeatable_count> value.

    ---
    elements:
      - type: Repeatable
        increment_field_names: 1
        elements:
          - name: foo_0
          - name: bar_0

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="foo_1" type="text" />
        <input name="bar_1" type="text" />
    </div>
    <div>
        <input name="foo_2" type="text" />
        <input name="bar_2" type="text" />
    </div>

See also L</counter_name>.

=head2 repeatable_count

This is set on each new L<Block|HTML::FormFu::Element::Block> element 
returned by L</repeat>, starting at number C<1>.

Because this is an 'inherited accessor' available on all elements, it can be
used to determine whether any element is a child of a Repeatable element.

=head2 attributes

=head2 attrs

Any attributes set will be passed to every repeated Block of elements.

    ---
    elements:
      - type: Repeatable
        attributes: 
          class: rep
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div class="rep">
        <input name="foo" type="text" />
    </div>
    <div class="rep">
        <input name="foo" type="text" />
    </div>

See L<HTML::FormFu/attributes> for details.

=head2 tag

The L</tag> value will be passed to every repeated Block of elements.

    ---
    elements:
      - type: Repeatable
        tag: span
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <span>
        <input name="foo" type="text" />
    </span>
    <span>
        <input name="foo" type="text" />
    </span>

See L<HTML::FormFu::Element::block/tag> for details.

=head2 auto_id

As well as the usual subtitutions, any instances of C<%r> will be 
replaced with the value of L</repeatable_count>.

See L<HTML::FormFu::Element::block/auto_id> for further details.

    ---
    elements:
      - type: Repeatable
        auto_id: "%n_%r"
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="foo" id="foo_1" type="text" />
    </div>
    <div>
        <input name="foo" id="foo_2" type="text" />
    </div>

=head2 content

Not supported for Repeatable elements - will throw a fatal error if called as
a setter.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
