#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_cpp.
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
require Objects_cpp;
require "gen_tools_cpp.pl";

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_exported_csv_helper_h__to_obj_name($$)
{
    my ( $namespace, $name ) = @_;

    return "static std::ostream & write( std::ostream & os, const $namespace::$name & r );";
}

sub generate_exported_csv_helper_h_body_1_core($$)
{
    my ( $namespace, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_csv_helper_h__to_obj_name( $namespace, $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_csv_helper_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums} );
}

sub generate_exported_csv_helper_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs} );
}

sub generate_exported_csv_helper_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs} );
}

sub generate_exported_csv_helper_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{msgs} );
}

sub generate_exported_csv_helper_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_exported_csv_helper_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_exported_csv_helper_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_exported_csv_helper_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_exported_csv_helper_h_body_4( $file_ref ) .
"\n";

    $body = gtcpp::namespacize( 'csv_encoder', $body );

    my $res = to_include_guards( $$file_ref, $body, "basic_parser", "exported_csv_helper", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################

sub generate_exported_csv_helper_cpp__to_enum__body($$)
{
    my ( $namespace, $name ) = @_;

    my $res =

"std::ostream & write( std::ostream & os, const $namespace::$name & r )\n" .
"{\n" .
"    write( os, static_cast<unsigned>( r ) );\n" .
"\n" .
"    return os;\n" .
"}\n";

    return $res;
}

sub generate_exported_csv_helper_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_exported_csv_helper_cpp__to_enum__body( get_namespace_name( $$file_ref ), $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_csv_helper_cpp__to_object__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    write( os, r.${name} );";

    return $res;
}

sub generate_exported_csv_helper_cpp__to_object__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_exported_csv_helper_cpp__to_object__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_exported_csv_helper_cpp__to_object__body($$$$)
{
    my ( $namespace, $msg, $is_message, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write( std::ostream & os, const $namespace::$name & r )\n" .
"{\n";

    if( $is_message )
    {
        $res .=
"    write( os, \"$protocol/$name\" );\n".
"\n";

        $res .=
"    // base class\n" .
"    write( os, static_cast<const " . $msg->get_base_class() . "&>( r ) );\n" .
"\n";
    }

    $res = $res .
    generate_exported_csv_helper_cpp__to_object__body__init_members( $msg ) .
"\n" .
"    return os;\n" .
"}\n";

    return $res;
}

sub generate_exported_csv_helper_cpp__to_object__core($$$)
{
    my ( $file_ref, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_csv_helper_cpp__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_csv_helper_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{objs}, 0 );
}

sub generate_exported_csv_helper_cpp__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0 );
}

sub generate_exported_csv_helper_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_exported_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{msgs}, 1 );
}

sub generate_exported_csv_helper_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/exported_csv_helper" );
    }

    return @res;
}

sub generate_exported_csv_helper_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_exported_csv_helper_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_exported_csv_helper_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_exported_csv_helper_cpp__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_exported_csv_helper_cpp__to_message( $file_ref )
;

    $body = gtcpp::namespacize( 'csv_encoder', $body );

    my @includes = ( "exported_csv_helper" );

    push( @includes, generate_exported_csv_helper_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/basic_csv_helper" );

    my $res = to_body( $$file_ref, $body, "basic_parser",  \@includes, [ ] );

    return $res;
}

###############################################

1;
