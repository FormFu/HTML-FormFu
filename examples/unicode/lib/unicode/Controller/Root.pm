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

sub default : Private {
    my ( $self, $c ) = @_;

    $c->response->body( <<HTML );
<html>
<body>
<a href="/tt">TT only</a><br />
<a href="tt_alloy">Template::Alloy only</a><br />
<a href="tt_cross">TT template, with HTML::FormFu using Template::Alloy</a><br />
<a href="tt_alloy_cross">Template::Alloy template, with HTML::FormFu using TT</a>
</body>
HTML
}

sub tt : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $self->_common( $c );
    
    $c->forward('View::TT');
}

sub tt_alloy : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $self->_common( $c );
    
    $c->stash->{form}->render_class_args->{TEMPLATE_ALLOY} = 1;
    
    $c->forward('View::TT::Alloy');
}

sub tt_cross : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $self->_common( $c );
    
    $c->stash->{form}->render_class_args->{TEMPLATE_ALLOY} = 1;
    
    $c->forward('View::TT');
}

sub tt_alloy_cross : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $self->_common( $c );
    
    $c->forward('View::TT::Alloy');
}

sub _common : Private {
    my ( $self, $c ) = @_;
    
    my $form = $c->stash->{form};
    
    if ( $form->submitted ) {
        $form->get_field('db')->comment("^ check this submitted value");
    }
    
    my $result = $c->model('DB')->resultset('Unicode')->find(1);
    
    $form->get_field('db')->default( $result->string );
    
    $c->stash->{template} = 'index.tt';
    
    return;
}

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
