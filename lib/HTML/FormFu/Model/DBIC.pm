package HTML::FormFu::Model::DBIC;
use strict;
use warnings;

use Storable qw( dclone );
use Carp qw( croak );

sub options_from_model {
    my ( $self, $base, $attrs ) = @_;

    $attrs ||= {};

    my $form    = $base->form;
    my $context = $form->stash->{context};
    my $schema  = $form->stash->{schema};
    return if !defined $context and !defined $schema;
    my $model = defined $schema ? $schema : $context->model( $attrs->{model} );
    return if !defined $model;

    $model = $model->resultset( $attrs->{resultset} )
        if defined $attrs->{resultset};

    my $rs         = $model->result_source;
    my $id_col     = $attrs->{id_column};
    my $label_col  = $attrs->{label_column};
    my $condition  = $attrs->{condition};
    my $attributes = $attrs->{attributes} || {};

    if ( !defined $id_col ) {
        ($id_col) = $rs->primary_columns;
    }

    if ( !defined $label_col ) {

        # use first text column
        ($label_col)
            = grep { $rs->column_info($_)->{data_type} =~ /text|varchar/i }
            $rs->columns;
    }
    $label_col = $id_col if !defined $label_col;

    $attributes->{'-columns'} = [ $id_col, $label_col ];

    my $result = $model->search( $condition, $attributes );

    my @defaults;

    if ( $attrs->{localize_label} ) {
        @defaults = map { { value => $_->id_col, label_loc => $_->label_col, } }
            $result->all;
    }
    else {
        @defaults = map { [ $_->$id_col, $_->$label_col ] } $result->all;
    }

    return @defaults;
}

sub defaults_from_model {
    my ( $self, $base, $dbic, $attrs ) = @_;

    $attrs ||= {};

    my $form = $base->form;

    $base = $form->get_all_element( { nested_name => $attrs->{nested_base} } )
        if defined $attrs->{nested_base}
            && ( !defined $base->nested_name
                || $base->nested_name ne $attrs->{nested_base} );

    my $rs = $dbic->result_source;

    _fill_in_fields( $base, $dbic, );
    _fill_nested( $self, $base, $dbic, );

    return $form;
}

# returns 0 if there is a node with nested_name set on the path from $field to $base
sub is_direct_child {
    my ( $base, $field ) = @_;

    while ( defined $field->parent ) {
        $field = $field->parent;

        return 1 if $base == $field;
        return 0 if defined $field->nested_name;
    }
}

# fills in values for all direct children fields of $base
sub _fill_in_fields {
    my ( $base, $dbic, ) = @_;
    for my $field ( @{ $base->get_fields } ) {
        my $name = $field->name;
        next if not defined $name;
        next if not is_direct_child( $base, $field );

        $name = $field->original_name if $field->original_name;

        my $accessor = exists $field->{db}{accessor}
            ? $field->{db}{accessor}
            : undef;
            
        if ( defined $accessor ) {
            $field->default( $dbic->$accessor );
        }
        elsif ( $dbic->can($name) ) {
            my $has_col = $dbic->result_source->has_column($name);
            my $has_rel = $dbic->result_source->has_relationship($name);

            if ( $has_col && $has_rel ) {

                # can't use direct accessor, if there's a rel of the same name
                $field->default( $dbic->get_column($name) );
            }
            elsif ( $has_col ) {
                $field->default( $dbic->$name );
            }
            elsif ( $field->multi_value ) {
                my ($col)
                    = defined $field->db && exists $field->db->{default_column}
                    ? $field->db->{default_column}
                    : $dbic->$name->result_source->primary_columns;

                my $info = $dbic->result_source->relationship_info($name);
                if ( !defined $info or $info->{attrs}{accessor} eq 'multi' ) {
                    my @defaults = $dbic->$name->get_column($col)->all;
                    $field->default( \@defaults );
                }
            }
        }
    }
}

# loop over all child blocks with nested_name that is a method on the DBIC row
# and recurse
sub _fill_nested {
    my ( $self, $base, $dbic ) = @_;

    for my $block ( @{ $base->get_all_elements } ) {
        next if $block->is_field;
        my $rel = $block->nested_name;
        # recursing only when $rel is a relation on $dbic
        next unless defined $rel and ( 
            $dbic->result_source->relationship_info($rel) or    
            $dbic->can( $rel ) && $dbic->can( 'add_to_' . $rel ) # many_to_many 
        ); 
        if ( $block->is_repeatable && $block->increment_field_names ) {

            # check there's a field name matching the PK
            my ($pk) = $dbic->$rel->result_source->primary_columns;
            next
                unless grep {
                $pk eq
                    ( defined $_->original_name ? $_->original_name : $_->name )
                } @{ $block->get_fields( { type => 'Hidden' } ) };

            my @rows = $dbic->$rel->all;
            my $count
                = $block->db->{new_empty_row}
                ? scalar @rows + 1
                : scalar @rows;

            my $blocks = $block->repeat($count);

            for my $rep ( 0 .. $#rows ) {
                defaults_from_model( $self, $blocks->[$rep], $rows[$rep], );
            }

            # set the counter field to the number of rows

            if ( defined( my $param_name = $block->counter_name ) ) {
                my $field = $base->get_field($param_name);

                $field->default($count)
                    if defined $field;
            }

            # remove 'delete' checkbox from the last repetition ?

            if ( $block->db->{new_empty_row} ) {
                my $last_rep = $block->get_elements->[-1];

                my ($del_field)
                    = grep { $_->db->{delete_if_true} }
                    @{ $last_rep->get_fields };

                if ( defined $del_field ) {
                    $last_rep->remove_element($del_field);
                }
            }
        }
        else {
            if ( defined( my $row = $dbic->$rel ) ) {
                defaults_from_model( $self, $block, $row );
            }
        }
    }
    return;
}

sub save_to_model {
    my ( $self, $base, $dbic, $attrs ) = @_;

    $attrs ||= {};

    my $form = $base->form;

    $base = $form->get_all_element( { nested_name => $attrs->{nested_base} } )
        if defined $attrs->{nested_base}
            && ( !defined $base->nested_name
                || $base->nested_name ne $attrs->{nested_base} );

    my %checkbox = map { $_->nested_name => 1 }
        grep { defined $_->name }
        @{ $base->get_fields( { type => 'Checkbox' } ) || [] };

    my $rs   = $dbic->result_source;
    my @rels = $rs->relationships;
    my @cols = $rs->columns;

    _save_columns( $base, $dbic, $form, $attrs, \%checkbox, \@rels, \@cols )
        or return;

    _save_non_columns( $base, $dbic, $form );

    $dbic->update_or_insert;

    _save_relationships( $self, $base, $dbic, $form, $rs, $attrs, \@rels );

    _save_multi_value_fields_many_to_many( $base, $dbic, $form, $attrs, \@rels,
        \@cols );

    _save_repeatable_many_to_many( $self, $base, $dbic, $form, $attrs, \@rels,
        \@cols );

    return $dbic;
}

sub _save_relationships {
    my ( $self, $base, $dbic, $form, $rs, $attrs, $rels ) = @_;

    return if $attrs->{no_follow};

    for my $rel (@$rels) {

        # don't follow rels to where we came from
        next
            if defined $attrs->{from}
                && $attrs->{from} eq $rs->related_source($rel)->result_class;

        my ($block)
            = grep { !$_->is_field }
            @{ $base->get_all_elements( { nested_name => $rel } ) };

        next if !defined $block;
        next if !$form->valid($rel);

        my $params = $form->param($rel);

        if ( $block->is_repeatable ) {

            # Handle has_many

            _save_has_many( $self, $dbic, $form, $rs, $block, $rel, $attrs );

        }
        elsif ( ref $params eq 'HASH' ) {
            my $target = $dbic->find_related( $rel, {} );

            if ( !defined $target && grep { length $_ } values %$params ) {
                $target = $dbic->create_related( $rel, {} );
            }

            next if !defined $target;

            save_to_model(
                $self, $block, $target,
                {   %$attrs,
                    nested_base => $rel,
                    from        => $dbic->result_class,
                } );
        }
    }
}

sub _save_has_many {
    my ( $self, $dbic, $form, $rs, $block, $rel, $attrs ) = @_;

    return unless $block->increment_field_names;

    # check there's a field name matching the PK

    my ($pk) = $rs->related_source($rel)->primary_columns;

    return
        unless grep { $_->original_name eq $pk }
            @{ $block->get_fields( { type => 'Hidden' } ) };

    my @blocks = @{ $block->get_elements };
    my $max    = $#blocks;

    # iterate over blocks, not rows
    # new rows might have been created in the meantime

    for my $i ( 0 .. $max ) {
        my $rep = $blocks[$i];

        # find PK field

        my ($pk_field)
            = grep { $_->original_name eq $pk }
            @{ $rep->get_fields( { type => 'Hidden' } ) };

        next if !defined $pk_field;

        my $value = $form->param_value( $pk_field->nested_name );
        my $row;

        if (   ( !defined $value || $value eq '' )
            && $i == $max
            && $block->db->{new_empty_row} )
        {

            # insert a new row
            $row = _insert_has_many( $dbic, $form, $block, $rep, $rel );

            next if !defined $row;
        }
        elsif ( !defined $value || $value eq '' ) {
            next;
        }
        else {
            $row = $dbic->find_related( $rel, $value );
        }
        next if !defined $row;

        # should we delete the row?

        next if _delete_has_many( $form, $row, $rep );

        save_to_model(
            $self, $rep, $row,
            {   %$attrs,
                repeat_base => $rel,
                from        => $dbic->result_class,
            } );
    }
}

sub _insert_has_many {
    my ( $dbic, $form, $outer, $repetition, $rel ) = @_;

    my $rows
        = ref $outer->db->{new_empty_row} eq 'ARRAY'
        ? $outer->db->{new_empty_row}
        : [ $outer->db->{new_empty_row} ];

    for my $name (@$rows) {
        my ($field)
            = grep { $_->original_name eq $name } @{ $repetition->get_fields };

        return if !defined $field;

        my $nested_name = $field->nested_name;
        return if !$form->valid($nested_name);

        my $value = $form->param_value($nested_name);
        return if !length $value;
    }

    my $row = $dbic->new_related( $rel, {} );

    return $row;
}

sub _delete_has_many {
    my ( $form, $row, $rep ) = @_;

    my ($del_field) = grep { $_->db->{delete_if_true} } @{ $rep->get_fields };

    return if !defined $del_field;

    my $nested_name = $del_field->nested_name;

    return
        unless $form->valid($nested_name)
            && $form->param_value($nested_name);

    $row->delete;

    return 1;
}

sub _save_columns {
    my ( $base, $dbic, $form, $attrs, $checkbox, $rels, $cols ) = @_;

    my @valid = $form->valid;

    for my $col (@$cols) {

        my $col_info    = $dbic->column_info($col);
        my $is_nullable = $col_info->{is_nullable} || 0;
        my $data_type   = $col_info->{data_type} || '';
        my $field;
        if ( defined $attrs->{repeat_base} ) {
            for my $f ( @{ $base->get_fields } ) {
                next unless $f->nested_base eq $attrs->{repeat_base};
                my $orig = $f->original_name;
                next unless defined $orig && $orig eq $col;
                $field = $f;
                last;
            }
        }
        else {
            $field = $base->get_field( { name => $col } );
        }
        
        next if defined $field
            && exists $field->{db}{accessor}
            && defined $field->{db}{accessor};

        my $nested_name = defined $field ? $field->nested_name : undef;

        my $value
            = defined $field
            ? $form->param_value( $field->nested_name )
            : (
            grep {
                      defined $attrs->{nested_base}
                    ? defined $nested_name
                        ? $nested_name eq $_
                        : 0
                    : $col eq $_
                } @valid
            )
            ? $form->param_value($col)
            : undef;

        if (   defined $field
            && $field->db->{delete_if_empty}
            && ( !defined $value || !length $value ) )
        {
            $dbic->discard_changes if $dbic->is_changed;
            $dbic->delete;
            return;
        }

        if ( (     $is_nullable
                || $data_type =~ m/^timestamp|date|int|float|numeric/i
            )
            && defined $value
            # comparing to '' does not work for inflated objects
            && ! ref $value 
            && $value eq ''
            )
        {
            $value = undef;
        }
        elsif (defined $nested_name
            && $checkbox->{$nested_name}
            && !defined $value
            && !$is_nullable )
        {
            $value = $col_info->{default_value};
        }
        elsif ( defined $value
            || ( defined $nested_name && $checkbox->{$nested_name} ) )
        {

            # keep $value
        }
        else {
            next;
        }

        if ( grep { $col eq $_ } @$rels ) {

            # relationship of the same name, can't use accessor

            $dbic->set_column( $col, $value );
        }
        else {
            $dbic->$col($value);
        }
    }

    return 1;
}

sub _save_non_columns {
    my ( $base, $dbic, $form, $attrs, $checkbox, $rels, $cols ) = @_;

    my @fields =
        grep { exists $_->{db}{accessor} && defined $_->{db}{accessor} } 
        @{ $base->get_fields };

    for my $field (@fields) {

        my $value = $form->param_value( $field->nested_name );

        if (   $field->db->{delete_if_empty}
            && ( !defined $value || !length $value ) )
        {
            $dbic->discard_changes if $dbic->is_changed;
            $dbic->delete;
            return;
        }

        next if !defined $value;
        
        my $accessor = $field->{db}{accessor};

        $dbic->$accessor($value);
    }

    return;
}

sub _save_multi_value_fields_many_to_many {
    my ( $base, $dbic, $form, $attrs, $rels, $cols ) = @_;

    my @fields = grep {
        defined $attrs->{nested_base}
            ? $_->parent->nested_name eq $attrs->{nested_base}
            : !$_->nested
        }
        grep { $_->multi_value }
        grep { defined $_->name } @{ $base->get_fields };

    for my $field (@fields) {
        my $name = $field->name;

        next if grep { $name eq $_ } @$rels, @$cols;

        if ( $dbic->can($name) ) {
            my $nested_name = $field->nested_name;

            next unless $form->valid($nested_name);

            my @values = $form->param_list($nested_name);

            my ($pk)
                = exists $field->db->{default_column}
                ? $field->db->{default_column}
                : $dbic->$name->result_source->primary_columns;

            my @rows = $dbic->$name->result_source->resultset->search(
                { "me.$pk" => { -in => \@values } } )->all;

            my $set_method = "set_$name";

            $dbic->$set_method( \@rows );
        }
    }
}

sub _save_repeatable_many_to_many {
    my ( $self, $base, $dbic, $form, $attrs, $rels, $cols ) = @_;

    my @blocks
        = grep { !$_->is_field && $_->is_repeatable && $_->increment_field_names }
        @{ $base->get_all_elements };

    for my $block (@blocks) {
        my $rel = $block->nested_name;

        next if grep { $rel eq $_ } @$rels, @$cols;

        if ( $dbic->can($rel) ) {

            # check there's a field name matching the PK

            my ($pk) = $dbic->$rel->result_source->primary_columns;

            my @blocks = @{ $block->get_elements };
            my $max    = $#blocks;

            # iterate over blocks, not rows
            # new rows might have been created in the meantime

            for my $i ( 0 .. $max ) {
                my $rep = $blocks[$i];

                # find PK field

                my ($pk_field)
                    = grep { $_->original_name eq $pk }
                    @{ $rep->get_fields( { type => 'Hidden' } ) };

                next if !defined $pk_field;

                my $value = $form->param_value( $pk_field->nested_name );
                my $row;
                my $is_new;

                if (   ( !defined $value || $value eq '' )
                    && $i == $max
                    && $block->db->{new_empty_row} )
                {

                    # insert a new row
                    $row = _insert_many_to_many( $dbic, $form, $block, $rep,
                        $rel );

                    next if !defined $row;

                    $is_new = 1;
                }
                elsif ( !defined $value || $value eq '' ) {
                    next;
                }
                else {
                    $row = $dbic->$rel->find($value);
                }
                next if !defined $row;

                # should we delete the row?

                next if _delete_many_to_many( $form, $dbic, $row, $rel, $rep );

                save_to_model(
                    $self, $rep, $row,
                    {   %$attrs,
                        repeat_base => $rel,
                        from        => $dbic->result_class,
                    } );

                if ($is_new) {

                    # new rows need to be related
                    my $add_method = "add_to_$rel";

                    $dbic->$add_method($row);
                }
            }
        }
    }
    return;
}

sub _insert_many_to_many {
    my ( $dbic, $form, $outer, $repetition, $rel ) = @_;

    my $rows
        = ref $outer->db->{new_empty_row} eq 'ARRAY'
        ? $outer->db->{new_empty_row}
        : [ $outer->db->{new_empty_row} ];

    for my $name (@$rows) {
        my ($field)
            = grep { $_->original_name eq $name } @{ $repetition->get_fields };

        return if !defined $field;

        my $nested_name = $field->nested_name;
        return if !$form->valid($nested_name);

        my $value = $form->param_value($nested_name);
        return if !length $value;
    }

    my $row = $dbic->$rel->new( {} );

    # add_to_* will be called later, after save_to_model is called on this row

    return $row;
}

sub _delete_many_to_many {
    my ( $form, $dbic, $row, $rel, $rep ) = @_;

    my ($del_field) = grep { $_->db->{delete_if_true} } @{ $rep->get_fields };

    return if !defined $del_field;

    my $nested_name = $del_field->nested_name;

    return
        unless $form->valid($nested_name)
            && $form->param_value($nested_name);

    my $remove = "remove_from_$rel";

    $dbic->$remove($row);

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Model::DBIC - Integrate HTML::FormFu with DBIx::Class

=head1 SYNOPSIS

Set a forms' default values from a DBIx::Class row object:

    my $row = $resultset->find( $id );
    
    $form->defaults_from_model( $row );

Update the database from a submitted form:

    if ( $form->submitted_and_valid ) {
        my $row = $resultset->find( $form->param('id') );
        
        $form->save_to_model( $row );
    }

=head1 METHODS

=head2 defaults_from_model

Arguments: $dbic_row, [\%config]

Return Value: $form

Set a form's default values from a DBIx::Class row.

Any form fields with a name matching a column name will have their default
value set with the column value.

=head3 might_have and has_one relationships

Set field values from a related row with a C<might_have> or C<has_one> 
relationship by placing the fields within a 
L<Block|HTML::FormFu::Element::Block> (or any element that inherits from 
Block, such as L<Fieldset|HTML::FormFu::Element::Fieldset>) with its
L<HTML::FormFu/nested_name> set to the relationships name.

For the following DBIx::Class schemas:

    package MySchema::Book;
    use strict;
    use warnings;
    
    use base 'DBIx::Class';
    
    __PACKAGE__->load_components(qw/ Core /);
    
    __PACKAGE__->table("book");
    
    __PACKAGE__->add_columns(
        id    => { data_type => "INTEGER" },
        title => { data_type => "TEXT" },
    );
    
    __PACKAGE__->set_primary_key("id");
    
    __PACKAGE__->might_have( review => 'MySchema::Review', 'book' );
    
    1;


    package MySchema::Review;
    use strict;
    use warnings;
    
    use base 'DBIx::Class';
    
    __PACKAGE__->load_components(qw/ Core /);
    
    __PACKAGE__->table("review");
    
    __PACKAGE__->add_columns(
        book   => { data_type => "INTEGER" },
        review => { data_type => "TEXT" },
    );
    
    __PACKAGE__->set_primary_key("book");
    
    __PACKAGE__->belongs_to( book => 'MySchema::Book' );
    
    1;


A suitable form for this would be:

    elements:
      - type: Hidden
        name: id
      
      - type: Text
        name: title
      
      - type: Block
        elements:
          - type: Text
            name: review

For C<might_have> and C<has_one> relationships, you generally shouldn't need
to have a field for the related table's primary key, as DBIx::Class will
handle retrieving the correct row automatically.

If you want the related row deleted if a particular field is empty, set
set C<delete_if_empty> on the field's L<db|HTML::FormFu::Element/db>. 

    elements:
      - type: Hidden
        name: id
      
      - type: Text
        name: title
      
      - type: Block
        elements:
          - type: Text
            name: review
            db:
              delete_if_empty: 1

=head3 has_many and many_to_many relationships

To edit fields in related rows with C<has_many> and C<many_to_many>
relationships, the fields must be placed within a 
L<Repeatable|HTML::FormFu::Element::Repeatable> element.
This will output a repetition of the entire block for each row returned.
L<HTML::FormFu::Element::Repeatable/increment_field_names> must be true
(which is the default value).

The block's L<nested_name|HTML::FormFu::Element::Repeatable/nested_name>
must be set to the name of the relationship.

If you want an extra, empty, copy of the block to be output, to allow the
user to add a new row of data, set the C<new_empty_row> key of the field's
L<db|HTML::FormFu::Element/db> hashref. The value must be a column name, or
arrayref of column names that must be filled in for the row to be added.

    ---
    element:
      - type: Repeatable
        nested_name: authors
        db: 
          new_empty_row: author
        
        elements:
          - type: Hidden
            name: id
          
          - type: Text
            name: author

If you want to provide a L<Checkbox|HTML::FormFu::Element::Checkbox> or
similar field, to allow the user to select whether given rows should be 
deleted (or, in the case of C<many_to_many> relationships, unrelated),
set C<delete_if_true> on the block's L<db|HTML::FormFu::Element/db> 
hashref to the name of that field.

    ---
    element:
      - type: Repeatable
        nested_name: authors
        db: 
          delete_if_true: delete
        
        elements:
          - type: Hidden
            name: id
          
          - type: Text
            name: author
          
          - type: Checkbox
            name: delete

=head3 many_to_many selection

To select / deselect rows from a C<many_to_many> relationship, you must use
a multi-valued element, such as a 
L<Checkboxgroup|HTML::FormFu::Element::Checkboxgroup> or a
L<Select|HTML::FormFu::Element::Select> with 
L<multiple|HTML::FormFu::Element::Select/multiple> set.

The field's L<name|HTML::FormFu::Element::_Field/name> must be set to the 
name of the C<many_to_many> relationship.

If you want to search / associate the related table by a column other it's
primary key, set the C<default_column> key on the field's 
L<db|HTML::FormFu::Element/db> hashref.

    ---
    element:
        - type: Checkboxgroup
          name: authors
          db:
            default_column: foo


=head3 non-column accessors

To make a form field correspond to a method in your DBIx::Class schema, that 
isn't a database column or relationship, set the C<accessor> key of the 
field's L<db|HTML::FormFu::Element/db> hashref.

    ---
    element:
      - type: Text
        name: foo
        db:
          accessor: method_name

=head2 save_to_model

Arguments: $dbic_row, [\%config]

Return Value: $dbic_row

Update the database with the submitted form values. Uses 
L<update_or_insert|DBIx::Class::Row/update_or_insert>.

See L</defaults_from_model> for specifics about what relationships are supported
and how to structure your forms.

=head1 FAQ

=head2 Add extra values not in the form

To save values to the database which weren't submitted to the form, 
you can first add them to the form with L<add_valid|HTML::FormFu/add_valid>.

    my $passwd = generate_passwd();
    
    $form->add_valid( passwd => $passwd );
    
    $form->save_to_model( $row );

C<add_valid> works for fieldnames that don't exist in the form.

=head1 CAVEATS

To ensure your column's inflators and deflators are called, we have to 
get / set values using their named methods, and not with C<get_column> / 
C<set_column>.

Because of this, beware of having column names which clash with DBIx::Class 
built-in method-names, such as C<delete>. - It will have obviously 
undesirable results!

=head1 SUPPORT

Project Page:

L<http://code.google.com/p/html-formfu/>

Mailing list:

L<http://lists.scsys.co.uk/cgi-bin/mailman/listinfo/html-formfu>

Mailing list archives:

L<http://lists.scsys.co.uk/pipermail/html-formfu/>

=head1 BUGS

Please submit bugs / feature requests to 
L<http://code.google.com/p/html-formfu/issues/list> (preferred) or 
L<http://rt.perl.org>.

=head1 SUBVERSION REPOSITORY

The publicly viewable subversion code repository is at 
L<http://html-formfu.googlecode.com/svn/trunk/HTML-FormFu-Model-DBIC>.

If you wish to contribute, you'll need a GMAIL email address. Then just 
ask on the mailing list for commit access.

If you wish to contribute but for some reason really don't want to sign up 
for a GMAIL account, please post patches to the mailing list (although  
you'll have to wait for someone to commit them). 

If you have commit permissions, use the HTTPS repository url: 
L<https://html-formfu.googlecode.com/svn/trunk/HTML-FormFu-Model-DBIC>

=head1 SEE ALSO

L<HTML::FormFu>, L<DBIx::Class>, L<Catalyst::Controller::HTML::FormFu>

=head1 AUTHOR

Carl Franks

=head1 CONTRIBUTORS

Based on the code of C<DBIx::Class::HTML::FormFu>, which was contributed to
by:

Adam Herzog

Daisuke Maki

Mario Minati

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Carl Franks

Based on the original source code of L<DBIx::Class::HTMLWidget>, copyright 
Thomas Klausner.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
