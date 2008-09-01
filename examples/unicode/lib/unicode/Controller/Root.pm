package unicode::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

unicode::Controller::Root - Root Controller for unicode

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub index : Chained : PathPart('') : Args(0) : FormConfig {
    my ( $self, $c ) = @_;
    
    my $form = $c->stash->{form};
    
    if ( $form->submitted_and_valid ) {
        my $demo_form = $self->form;
        
        my $config_file = $c->path_to(
            'root/forms/view'
            . $form->param_value('config_file_ext')
        );
        
        $demo_form->load_config_file( $config_file );
        
        $demo_form->render_method( $form->param_value('render_method') );
        $demo_form->tt_module(     $form->param_value('tt_module') );
        
        my $db_row = $c->model('DB')->resultset('Unicode')->find(1);
        
        $demo_form->get_field('db')->default( $db_row->string );
        
        $demo_form->process({});
        
        $c->stash->{demo_form} = $demo_form;
        $c->stash->{template}  = 'view.tt';
        
        $c->forward( $form->param_value('view_class' ) );
    }
    else {
        $c->stash->{template} = 'index.tt';
        $c->forward('View::TT');
    }
}

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
