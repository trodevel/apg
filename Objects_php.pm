#!/usr/bin/perl -w

# Objects
#
# Copyright (C) 2016 Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# $Revision: 13204 $ $Date:: 2020-06-06 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Objects;
require Elements_php;
require "gen_tools.pl";
require "gen_tools_php.pl";

############################################################
package IObject;

sub to_php_decl()
{
    my( $self ) = @_;
    return '#error not implemented yet';
}

sub has_base_class_php()
{
    my( $self ) = @_;

    die "not defined for object $self->{name}";
}

sub get_base_class_php()
{
    my( $self ) = @_;

    die "not defined for object $self->{name}";
}

sub get_full_base_class_php()
{
    my( $self ) = @_;

    return "\\" . $self->get_protocol_name() . "\\Object";
}

sub get_full_base_class_apg_php()
{
    my ( $self ) = @_;

    return "\\apg\\" . $self->get_full_base_class_php();
}

sub get_protocol_name_php
{
    my ( $self ) = @_;

    if( not defined $self->{protocol} || ( defined $self->{protocol} && $self->{protocol} eq '' ) )
    {
        die "protocol is not defined for " . $self->{name} . "\n";
    }

    return $self->{protocol};
}

sub get_full_name_php()
{
    my ( $self ) = @_;

    return "\\" . $self->get_protocol_name_php() . "\\" . $self->{name};
}

sub get_full_name_apg_php()
{
    my ( $self ) = @_;

    return "\\apg\\" . $self->get_full_name_php();
}

sub get_optional_base_class_suffix_php($$)
{
    my( $self ) = @_;

    my $base_class = "\\basic_parser\\Object";

    if( $self->has_base_class_php() )
    {
        $base_class = $self->get_base_class_php();
    }

    return " extends $base_class";
}

############################################################
package Enum;

sub to_php_decl
{
    my( $self ) = @_;

    my $res =
"// Enum " . $self->{name} . "\n";

    foreach( @{ $self->{elements} } )
    {
        $res .= $_->to_php_decl( $self->{name} ) . "\n";
    }

    return $res;
}

# @return name with parent name
sub get_full_name_php
{
    my ( $self ) = @_;

    my $parent = "";

    if( defined $self->{parent} && $self->{parent} ne '' )
    {
        $parent = $self->{parent} . "\\";
    }

    return $self->get_protocol_name_php() . "\\" . $parent . $self->{name};
}

############################################################
package ObjectWithMembers;

sub has_base_class_php()
{
    my( $self ) = @_;

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        return 1;
    }

    return 0;
}

sub get_base_class_php()
{
    my( $self ) = @_;

    if ( $self->has_base_class() == 0 )
    {
        my $i = 1;
        print STDERR "Stack Trace:\n";
        while ( (my @call_details = (caller($i++))) )
        {
            print STDERR $call_details[1].":".$call_details[2]." in function ".$call_details[3]."\n";
        }

        die "no base class for object $self->{name}";
    }

    return $self->{base_class};
}

############################################################
package Object;

sub to_php_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"class " . $self->{name} . "\n";

    my @array = @{ $self->{members} };

    my $body = gtphp::array_to_decl( $self->{enums} );

    $body = $body . gtphp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package BaseMessage;

sub to_php_decl
{
    my( $self ) = @_;

    my $res =
"// Base message\n" .
"class " . $self->{name} . $self->get_optional_base_class_suffix_php() . "\n";

    my @array = @{ $self->{members} };

    my $body = gtphp::array_to_decl( $self->{enums} );

    $body = $body . gtphp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Message;

sub to_php_decl
{
    my( $self ) = @_;

    my $res =
"// Message\n" .
"class " . $self->{name} . $self->get_optional_base_class_suffix_php() . "\n";

    my $body =

"function __construct()\n" .
"{\n" .
"    parent::__construct();\n" .
"}\n" .
"\n";

    $body = $body . "const MESSAGE_ID = " . $self->{message_id} . ";\n\n";

    my @array = @{ $self->{members} };

    $body = $body . gtphp::array_to_decl( $self->{enums} );

    $body = $body . gtphp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
