#!/usr/bin/perl -w

# $Revision: 5016 $ $Date:: 2016-11-16 #$ $Author: serge $
# 1.0   - 16b09 - initial version

############################################################

require "mycrc32.pl";
require "Objects.pm";

package File;
use strict;
use warnings;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        base_prot   => undef, # base protocol
        prot_object => BaseMessage->new( "XObject" ), # protocol base object
        includes  => [],    # includes
        enums     => [],    # enums
        objs      => [],    # objects
        base_msgs => [],    # base messages
        msgs      => [],    # messages
    };

    bless $self, $class;
    return $self;
}

sub set_base_prot
{
    my ( $self, $elem ) = @_;

    $self->{base_prot}   = $elem;
#    $self->{prot_object}->set_base_class( $elem );
}

sub add_include
{
    my ( $self, $elem ) = @_;

    push @{ $self->{includes} }, $elem;
}

sub add_enum
{
    my ( $self, $elem ) = @_;

    push @{ $self->{enums} }, $elem;
}

sub add_obj
{
    my ( $self, $elem ) = @_;

    $elem->set_base_prot( $self->{base_prot} );

    push @{ $self->{objs} }, $elem;
}

sub add_base_msg
{
    my ( $self, $elem ) = @_;

    $elem->set_base_prot( $self->{base_prot} );

    push @{ $self->{base_msgs} }, $elem;
}

sub add_msg
{
    my ( $self, $elem ) = @_;

    $elem->{message_id} = main::mycrc32( $self->{name} . ':' . $elem->{name} );

    $elem->set_base_prot( $self->{base_prot} );

    push @{ $self->{msgs} }, $elem;
}

############################################################

1;
