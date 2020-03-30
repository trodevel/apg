#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_php.
#
# Copyright (C) 2019 Sergey Kolevatov
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

# $Id $
# SKV 19c25

# 1.0 - 19c25 - initial commit

###############################################

require File;
require Objects_php;
require "gen_tools_php.pl";

###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_exported_str_helper_h__to_obj_name($$)
{
    my ( $namespace, $name ) = @_;

    return "static std::ostream & write( std::ostream & os, const $namespace::$name & r );";
}

sub generate_exported_str_helper_h_body_1_core($$)
{
    my ( $namespace, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_str_helper_h__to_obj_name( $namespace, $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_str_helper_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_exported_str_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums} );
}

sub generate_exported_str_helper_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_exported_str_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs} );
}

sub generate_exported_str_helper_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_exported_str_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs} );
}

sub generate_exported_str_helper_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_exported_str_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{msgs} );
}

sub generate_exported_str_helper_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_exported_str_helper_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_exported_str_helper_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_exported_str_helper_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_exported_str_helper_h_body_4( $file_ref ) .
"\n";

    $body = gtphp::namespacize( 'str_helper', $body );

    my $res = to_include_guards( $$file_ref, $body, "basic_parser", "exported_str_helper", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################

sub generate_str_helper_php__to_enum__body__init_members__body($$)
{
    my ( $enum_name, $name ) = @_;

    return "${enum_name}_${name} => '$name',";
}

sub generate_str_helper_php__to_enum__body__init_members($)
{
    my ( $enum ) = @_;

    my $res = "";

    foreach( @{ $enum->{elements} } )
    {
        $res .= generate_str_helper_php__to_enum__body__init_members__body( $enum->{name}, $_->{name} ) . "\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}


sub generate_str_helper_php__to_enum__body($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function to_string_${name}( \$r )\n" .
"{\n" .
"    \$map = array(\n" .
"    {\n";

    $res .= generate_str_helper_php__to_enum__body__init_members( $enum );

    $res .=
"    );\n" .
"\n" .
"    if( array_key_exists( \$r, \$map ) )\n" .
"    {\n" .
"        return \$map[ \$r ];\n" .
"    }\n" .
"\n" .
"    return '?';\n" .
"}\n";

    return $res;
}

sub generate_str_helper_php__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_str_helper_php__to_enum__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    \$res .= \" ${name}=\" . " . $obj->{data_type}->to_php__to_string_func_name() . "( \$r->${name} );";

    return $res;
}

sub generate_str_helper_php__to_object__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_str_helper_php__to_object__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object__body($$$$)
{
    my ( $namespace, $msg, $is_message, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"function to_string_${name}( & \$r )\n" .
"{\n";

    if( $is_message )
    {
        $res .=
"    // base class\n" .
"    \$res = " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "to_string" ). "( \$r );\n" .
"\n";
    }


    if( $is_message == 0 )
    {
        $res .= "    \$res = \"(\";\n\n";
    }

    $res .=
    generate_str_helper_php__to_object__body__init_members( $msg ) .
"\n";

    if( $is_message == 0 )
    {
        $res .= "    \$res .= \")\";\n\n";
    }

    $res .=

"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_str_helper_php__to_object__core($$$)
{
    my ( $file_ref, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_str_helper_php__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{objs}, 0 );
}

sub generate_str_helper_php__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0 );
}

sub generate_str_helper_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{msgs}, 1 );
}

sub generate_str_helper_php__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/str_helper" );
    }

    return @res;
}

sub generate_str_helper_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_str_helper_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_str_helper_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_str_helper_php__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_str_helper_php__to_message( $file_ref )
;

    my @includes = ( "exported_str_helper" );

    push( @includes, $$file_ref->{base_prot} . "/str_helper" );

    push( @includes, generate_str_helper_php__to_includes( $file_ref ) );

    push( @includes, "basic_parser/str_helper" );

    my $res = to_body( $$file_ref, $body, get_namespace_name( $$file_ref ),  \@includes, [ ] );

    return $res;
}

###############################################

1;
