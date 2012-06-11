package HTML::FormFu::Element::Repeatable;

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Element::Block';

use HTML::FormFu::Util qw( DEBUG_PROCESS debug );
use List::Util qw( first );
use Carp qw( croak );

has counter_name       => ( is => 'rw', traits => ['Chained'] );

has _original_elements => ( is => 'rw' );

has increment_field_names => (
    is      => 'rw',
    default => 1,
    lazy    => 1,
    traits  => ['Chained'],
);

# This attribute is currently not documented as FF::Model::HashRef
# only supports '_'

has repeatable_delimiter => (
    is      => 'rw',
    default => '_',
    lazy    => 1,
    traits  => ['Chained'],
);

after BUILD => sub {
    my $self = shift;

    $self->filename('repeatable');
    $self->is_repeatable(1);

    return;
};

sub repeat {
    my ( $self, $count ) = @_;

    croak "invalid number to repeat"
        if $count !~ /^[0-9]+\z/;

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

    return [] if !$count;

    # switch behaviour
    # If nested_name is set, we add the repeatable counter to the name
    # of the containing block (this repeatable block).
    #     This behaviour eases the creation of client side javascript code
    #     to add and remove repeatable elements client side.
    # If nested_name is *not* set, we add the repeatable counter to the names
    # of the child elements (leaves of the element tree).
    my $nested_name = $self->nested_name;
    if (defined $nested_name && length $nested_name) {
        return $self->_repeat_containing_block( $count );
    }
    else {
        return $self->_repeat_child_elements( $count );
    }
}

sub _repeat_containing_block {
    my ( $self, $count ) = @_;

    my $children = $self->_original_elements;

    # We must not get 'nested.nested_1' instead of 'nested_1' through the
    # nested_name attribute of the Repeatable element, thus we extended
    # FF::Elements::_Field nested_names method to ignore Repeatable elements.
    my $nested_name = $self->nested_name;
    $self->original_nested_name( $nested_name );

    # delimiter between nested_name and the incremented counter
    my $delimiter = $self->repeatable_delimiter;

    my @return;

    for my $rep ( 1 .. $count ) {
        # create clones of elements and put them in a new block
        my @clones = map { $_->clone } @$children;
        my $block = $self->element('Block');

        # initiate new block with properties of this repeatable
        $block->_elements( \@clones );
        $block->attributes( $self->attributes );
        $block->tag( $self->tag );

        $block->repeatable_count($rep);

        if ( $self->increment_field_names ) {
            # store the original nested_name attribute for later usage when
            # building the original nested name
            $block->original_nested_name( $block->nested_name )
                if !defined $block->original_nested_name;

            # create new nested name with repeat counter
            $block->nested_name( $nested_name . $delimiter . $rep );

            for my $field ( @{ $block->get_fields } ) {

                if ( defined( my $name = $field->name ) ) {
                    # store original name for later usage when
                    # replacing the field names in constraints
                    $field->original_name($name)
                        if !defined $field->original_name;

                    # store original nested name for later usage when
                    # replacing the field names in constraints
                    $field->original_nested_name( $field->build_original_nested_name )
                        if !defined $field->original_nested_name;
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
                @{ $field->_transformers },
                @{ $field->_plugins },
                ;
        }

        my $block_fields = $block->get_fields;

        my @block_constraints = map { @{ $_->get_constraints } } @$block_fields;

        # rename any 'others' fields
        my @others_constraints = grep { defined $_->others }
            grep { $_->can('others') } @block_constraints;

        for my $constraint (@others_constraints) {
            my $others = $constraint->others;
            if ( !ref $others ) {
                $others = [$others];
            }
            my @new_others;

            for my $name (@$others) {
                my $field
                    = ( first { $_->original_nested_name eq $name }
                    @$block_fields )
                    || first { $_->original_name eq $name } @$block_fields;

                if ( defined $field ) {
                    push @new_others, $field->nested_name;
                }
                else {
                    push @new_others, $name;
                }
            }

            $constraint->others( \@new_others );
        }

        # rename any 'when' fields
        my @when_constraints = grep { defined $_->when } @block_constraints;

        for my $constraint (@when_constraints) {
            my $when = $constraint->when;
            my $name = $when->{field};

            my $field
                = first { $_->original_nested_name eq $name } @$block_fields;

            if ( defined $field ) {
                $when->{field} = $field->nested_name;
            }
        }

        push @return, $block;

    }

    return \@return;
}

sub _repeat_child_elements {
    my ( $self, $count ) = @_;

    my $children = $self->_original_elements;

    # delimiter between nested_name and the incremented counter
    my $delimiter = $self->repeatable_delimiter;

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
                    $field->original_name($name)
                        if !defined $field->original_name;

                    $field->original_nested_name( $field->nested_name )
                        if !defined $field->original_nested_name;

                    $field->name(${name} . $delimiter . $rep);
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
                @{ $field->_transformers },
                @{ $field->_plugins },
                ;
        }

        my $block_fields = $block->get_fields;

        my @block_constraints = map { @{ $_->get_constraints } } @$block_fields;

        # rename any 'others' fields
        my @others_constraints = grep { defined $_->others }
            grep { $_->can('others') } @block_constraints;

        for my $constraint (@others_constraints) {
            my $others = $constraint->others;
            if ( !ref $others ) {
                $others = [$others];
            }
            my @new_others;

            for my $name (@$others) {
                my $field
                    = ( first { $_->original_nested_name eq $name }
                    @$block_fields )
                    || first { $_->original_name eq $name } @$block_fields;

                if ( defined $field ) {
                    push @new_others, $field->nested_name;
                }
                else {
                    push @new_others, $name;
                }
            }

            $constraint->others( \@new_others );
        }

        # rename any 'when' fields
        my @when_constraints = grep { defined $_->when } @block_constraints;

        for my $constraint (@when_constraints) {
            my $when = $constraint->when;
            my $name = $when->{field};

            my $field
                = first { $_->original_nested_name eq $name } @$block_fields;

            if ( defined $field ) {
                $when->{field} = $field->nested_name;
            }
        }

        # rename any 'id_field' fields
        my @id_field_constraints = grep { defined $_->id_field } 
            grep { $_->can('id_field') } @block_constraints;

        for my $constraint (@id_field_constraints) {
            my $id_field = $constraint->id_field;
            my $name = $id_field;

            my $field
                = first { $_->original_nested_name eq $name } @$block_fields;

            if ( defined $field ) {
                $constraint->id_field( $field->nested_name );
            }
        }

        push @return, $block;

    }

    return \@return;
}

sub _reparent_children {
    my $self = shift;

    return if !$self->is_block;

    for my $child ( @{ $self->get_elements } ) {
        $child->parent($self);

        _reparent_children($child);
    }
}

sub process {
    my $self = shift;

    my $counter_name = $self->counter_name;
    my $form         = $self->form;
    my $count        = 1;

    if ( defined $counter_name && defined $form->query ) {
        # are we in a nested-repeatable?
        my $parent = $self;

        while ( defined( $parent = $parent->parent ) ) {
            my $field = $parent->get_field({ original_name => $counter_name });

            if ( defined $field ) {
                $counter_name = $field->nested_name;
                last;
            }
        }

        my $input = $form->query->param( $counter_name );

        if ( defined $input && $input =~ /^[1-9][0-9]*\z/ ) {
            $count = $input;
        }
    }

    if ( !$self->_original_elements ) {
        DEBUG_PROCESS && debug("calling \$repeatable->count($count)");

        $self->repeat($count);
    }

    return $self->SUPER::process(@_);
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

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Repeatable - repeatable block element

=head1 SYNOPSIS

    ---
    elements:
      - type: Repeatable
        name: my_rep
        elements:
          - name: foo
          - name: bar

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="my_rep.foo_1" type="text" />
        <input name="my_rep.bar_1" type="text" />
    </div>
    <div>
        <input name="my_rep.foo_2" type="text" />
        <input name="my_rep.bar_2" type="text" />
    </div>

Example of constraints:

    ----
    elements:
      - type: Repeatable
        name: my_rep
        elements:
          - name: id

          - name: foo
            constraints:
              - type: Required
                when:
                  field: 'my_rep.id' # use full nested-name

          - name: bar
            constraints:
              - type: Equal
                others: 'my_rep.foo' # use full nested-name

=head1 DESCRIPTION

Provides a way to extend a form at run-time, by copying and repeating its
child elements.

The elements intended for copying must be added before L</repeat> is called.

Although the Repeatable element inherits from
L<Block|HTML::FormFu::Element::Block>, it doesn't generate a block tag
around all the repeated elements - instead it places each repeat of the
elements in a new L<Block|HTML::FormFu::Element::Block> element, which
inherits the Repeatable's display settings, such as L</attributes> and
L</tag>.

For all constraints attached to fields within a Repeatable block which use
either L<others|HTML::FormFu::Constraint::_others/others> or
L<when|HTML::FormFu::Constraint/when> containing names of fields within
the same Repeatable block, when L<repeat> is called, those names will
automatically be updated to the new nested-name for each field (taking
into account L<increment_field_names>).

=head1 METHODS

=head2 repeat

Arguments: [$count]

Return Value: $arrayref_of_new_child_blocks

This method creates C<$count> number of copies of the child elements.
If no argument C<$count> is provided, it defaults to C<1>.

Note that C<< $form->process >> will call L</repeat> automatically to ensure the
initial child elements are correctly set up - unless you call L</repeat>
manually first, in which case the child elements you created will be left
untouched (otherwise L<process|HTML::FormFu/process> would overwrite your
changes).

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

If true, then all fields will have C<< _n >> appended to their name, where
C<n> is the L</repeatable_count> value.

=head2 repeatable_count

This is set on each new L<Block|HTML::FormFu::Element::Block> element
returned by L</repeat>, starting at number C<1>.

Because this is an 'inherited accessor' available on all elements, it can be
used to determine whether any element is a child of a Repeatable element.

Only available after L<repeat> has been called.

=head2 nested_name

If the L</nested_name> attribute is set, the naming scheme of the Repeatable
element's children is switched to add the counter to the repeatable blocks
themselves.

    ---
    elements:
      - type: Repeatable
        nested_name: my_rep
        elements:
          - name: foo
          - name: bar

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="my_rep_1.foo" type="text" />
        <input name="my_rep_1.bar" type="text" />
    </div>
    <div>
        <input name="my_rep_2.foo" type="text" />
        <input name="my_rep_2.bar" type="text" />
    </div>


Because this is an 'inherited accessor' available on all elements, it can be
used to determine whether any element is a child of a Repeatable element.

=head2 attributes

=head2 attrs

Any attributes set will be passed to every repeated Block of elements.

    ---
    elements:
      - type: Repeatable
        name: my_rep
        attributes:
          class: rep
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div class="rep">
        <input name="my_rep.foo_1" type="text" />
    </div>
    <div class="rep">
        <input name="my_rep.foo_2" type="text" />
    </div>

See L<HTML::FormFu/attributes> for details.

=head2 tag

The L</tag> value will be passed to every repeated Block of elements.

    ---
    elements:
      - type: Repeatable
        name: my_rep
        tag: span
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <span>
        <input name="my_rep.foo_1" type="text" />
    </span>
    <span>
        <input name="my_rep.foo_2" type="text" />
    </span>

See L<HTML::FormFu::Element::Block/tag> for details.

=head2 auto_id

As well as the usual subtitutions, any instances of C<%r> will be
replaced with the value of L</repeatable_count>.

See L<HTML::FormFu::Element::Block/auto_id> for further details.

    ---
    elements:
      - type: Repeatable
        name: my_rep
        auto_id: "%n_%r"
        elements:
          - name: foo

Calling C<< $element->repeat(2) >> would result in the following markup:

    <div>
        <input name="my_rep.foo_1" id="foo_1" type="text" />
    </div>
    <div>
        <input name="my_rep.foo_2" id="foo_2" type="text" />
    </div>

=head2 content

Not supported for Repeatable elements - will throw a fatal error if called as
a setter.

=head1 CAVEATS

=head2 Unsupported Constraints

Note that constraints with an L<others|HTML::FormFu::Constraint::_others> 
method do not work correctly within a Repeatable block. Currently, these are:
L<AllOrNone|HTML::FormFu::Constraint::AllOrNone>, 
L<DependOn|HTML::FormFu::Constraint::DependOn>, 
L<Equal|HTML::FormFu::Constraint::Equal>, 
L<MinMaxFields|HTML::FormFu::Constraint::MinMaxFields>, 
L<reCAPTCHA|HTML::FormFu::Constraint::reCAPTCHA>.
Also, the L<CallbackOnce|HTML::FormFu::Constraint::CallbackOnce> constraint
won't work within a Repeatable block, as it wouldn't make much sense.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Element::Block>,
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
