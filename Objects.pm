#!/usr/bin/perl -w

# $Revision: 4911 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
package IObject;
use strict;
use warnings;

require Elements;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        members   => shift,
    };

    bless $self, $class;
    return $self;
}

############################################################
package Enum;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[3] );

    $self->{data_type}  = $_[2];

    bless $self, $class;
    return $self;
}

############################################################
package Object;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    bless $self, $class;
    return $self;
}

############################################################
package BaseMessage;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    $self->{base_class}  = $_[3];

    bless $self, $class;
    return $self;
}

############################################################
package Message;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    $self->{base_class}  = $_[3];
    $self->{message_id}  = 0;

    bless $self, $class;
    return $self;
}

############################################################
