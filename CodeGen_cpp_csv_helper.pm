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

sub generate_csv_helper_h__to_obj_name($)
{
    my ( $name ) = @_;

    return "std::ostream & write( std::ostream & os, const $name & r );";
}

sub generate_csv_helper_h_body_1_core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_csv_helper_h__to_obj_name( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_csv_helper_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_h_body_1_core( $$file_ref->{enums} );
}

sub generate_csv_helper_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_h_body_1_core( $$file_ref->{objs} );
}

sub generate_csv_helper_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_h_body_1_core( $$file_ref->{base_msgs} );
}

sub generate_csv_helper_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_h_body_1_core( $$file_ref->{msgs} );
}

sub generate_csv_helper_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_csv_helper_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_csv_helper_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_csv_helper_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_csv_helper_h_body_4( $file_ref ) .
"\n".
"template<class T>\n" .
"std::string to_csv( const T & l )\n" .
"{\n" .
"    std::ostringstream os;\n" .
"\n" .
"    write( os, l );\n" .
"\n" .
"    return os.str();\n" .
"}\n" .
"\n".
"// generic\n" .
"std::ostream & write( std::ostream & os, const generic_protocol::Object & r );\n" .
"\n";

    $body = gtcpp::namespacize( 'csv_helper', $body );

    my $res = to_include_guards( $$file_ref, $body, "", "csv_helper", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################

sub generate_csv_helper_cpp__write__body($)
{
    my $name = shift;

    return "HANDLER_MAP_ENTRY( $name )";
}

sub generate_csv_helper_cpp__write($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_csv_helper_cpp__write__body( $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_csv_helper_cpp__to_enum__body($)
{
    my ( $name ) = @_;

    my $res =

"std::ostream & write( std::ostream & os, const $name & r )\n" .
"{\n" .
"    write( os, static_cast<unsigned>( r ) );\n" .
"\n" .
"    return os;\n" .
"}\n";

    return $res;
}

sub generate_csv_helper_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res .= generate_csv_helper_cpp__to_enum__body( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_csv_helper_cpp__to_object__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = "    " . $obj->{data_type}->to_cpp__to_csv_func_name() . "( os, r.${name}, " . $obj->{data_type}->{value_type}->to_cpp__to_csv_func_ptr() . " ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = "    " . $obj->{data_type}->to_cpp__to_csv_func_name() .
            "( os, r.${name}, " .
            $obj->{data_type}->{key_type}->to_cpp__to_csv_func_ptr() . ", " .
            $obj->{data_type}->{mapped_type}->to_cpp__to_csv_func_ptr() . " ); // Map";
    }
    else
    {
        $res = "    " . $obj->{data_type}->to_cpp__to_csv_func_name() . "( os, r.${name} );";
    }

    return $res;
}

sub generate_csv_helper_cpp__to_object__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res .= generate_csv_helper_cpp__to_object__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_csv_helper_cpp__to_object__body($$$)
{
    my ( $msg, $is_message, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write( std::ostream & os, const $name & r )\n" .
"{\n";

    if( $is_message )
    {
        $res .=
"    write( os, std::string( \"$protocol/$name\" ) );\n".
"\n";

        $res .=
"    // base class\n" .
"    " . gtcpp::to_function_call_with_namespace( $msg->get_base_class(), "csv_helper::write" ). "( os, static_cast<const " . $msg->get_base_class() . "&>( r ) );\n" .
"\n";
    }

    $res .=
    generate_csv_helper_cpp__to_object__body__init_members( $msg ) .
"\n" .
"    return os;\n" .
"}\n";

    return $res;
}

sub generate_csv_helper_cpp__to_object__core($$$)
{
    my ( $file_ref, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_csv_helper_cpp__to_object__body( $_, $is_message, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_csv_helper_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{objs}, 0 );
}

sub generate_csv_helper_cpp__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0 );
}

sub generate_csv_helper_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_csv_helper_cpp__to_object__core( $file_ref,  $$file_ref->{msgs}, 1 );
}

sub generate_csv_helper_cpp__write_message__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write_${name}( std::ostream & os, const generic_protocol::Object & rr )\n" .
"{\n" .
"    auto & r = dynamic_cast< const $name &>( rr );\n".
"\n" .
"    return write( os, r );\n" .
"}\n";

    return $res;
}

sub generate_csv_helper_cpp__write_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res .= generate_csv_helper_cpp__write_message__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_csv_helper_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/csv_helper" );
    }

    return @res;
}

sub generate_csv_helper_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"using ::basic_parser::csv_helper::write;\n" .
"using ::basic_parser::csv_helper::write_t;\n" .
"\n" .
"// enums\n" .
"\n" .
    generate_csv_helper_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_csv_helper_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_csv_helper_cpp__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_csv_helper_cpp__to_message( $file_ref )
;

    $body .=

    generate_csv_helper_cpp__write_message( $file_ref ) .
"\n" .
"std::ostream & write( std::ostream & os, const generic_protocol::Object & r )\n" .
"{\n" .
"    typedef std::ostream & (*PPMF)( std::ostream & os, const generic_protocol::Object & );\n" .
"\n" .
"#define HANDLER_MAP_ENTRY(_v)       { typeid( _v ),        & write_##_v }\n" .
"\n" .
"    static const std::map<std::type_index, PPMF> funcs =\n" .
"    {\n" .

    generate_csv_helper_cpp__write( $file_ref ) .

"    };\n" .
"\n" .
"#undef HANDLER_MAP_ENTRY\n" .
"\n" .
"    auto it = funcs.find( typeid( r ) );\n" .
"\n" .
"    if( it != funcs.end() )\n" .
"        return it->second( os, r );\n" .
"\n" .
"    return ::generic_protocol::csv_helper::write( os, r );\n" .
"}\n" .
"\n"
;

    $body = gtcpp::namespacize( 'csv_helper', $body );

    my @includes = ( "csv_helper" );

    push( @includes, $$file_ref->{base_prot} . "/csv_helper" );

    push( @includes, generate_csv_helper_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/csv_helper" );

    my $res = to_body( $$file_ref, $body, "",  \@includes, [ "map", "typeindex" ] );

    return $res;
}

###############################################

1;
