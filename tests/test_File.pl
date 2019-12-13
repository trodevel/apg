#!/usr/bin/perl -w

# $Revision: 12501 $ $Date:: 2019-12-13 #$ $Author: serge $
# 1.0   - 16b04 - initial version

my $VER="1.0";

BEGIN {push @INC, '..'}

use strict;
use warnings;
use File_cpp;
use File_cpp_json;

my $file = new File( "example" );

$file->set_base_prot( "communication" );
$file->add_include( "../generic" );
$file->add_include( "communication" );


{
    my $obj = new ConstElement( new Integer( 1, 16 ), "HTTP_PORT", 80 );
    $file->add_const( $obj );
}
{
    my $obj = new ConstElement( new Float( 1 ), "PI", 3.141592 );
    $file->add_const( $obj );
}
{
    my $obj = new Object( "SomeObject" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $file->add_obj( $obj );
}
{
    my $obj = new Object( "AnotherObject" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 ) );
    $file->add_obj( $obj );
}
{
    my $obj = new Object( "TimeRange24" );
    $obj->add_member( new ElementExt( new Integer( 1, 8 ), "hh", new ValidRange( 1, 0, 1, 1, 23, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Integer( 1, 8 ), "mm", new ValidRange( 1, 0, 1, 1, 59, 1 ), 0 ) );
    $file->add_obj( $obj );
}
{
    my $obj = new BaseMessage( "GenericRequest", undef );
    $obj->add_member( new ElementExt( new Integer( 1, 32 ), "user_id", new ValidRange( 1, 1, 1, 1, 32768, 0 ), 0 ) );
    $file->add_base_msg( $obj );
}
{
    my $obj = new Message( "Request", undef );
    $file->add_msg( $obj );
}
{
    my $obj = new Message( "Request1", "base::Request" );
    $file->add_msg( $obj );
}
{
    my $obj = new Message( "Request2", "base::Request" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ) );
    $obj->add_member( new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ) );
    $file->add_msg( $obj );
}
{
    my $obj = new Enum( "Colors", new Integer( 0, 8 ) );
    $obj->add_element( new EnumElement( "RED", undef ) );
    $obj->add_element( new EnumElement( "GREEN", undef ) );
    $obj->add_element( new EnumElement( "BLUE", undef ) );
    $file->add_enum( $obj );
}
{
    my $enum = new Enum( "State", new Integer( 0, 8 ) );

    $enum->add_element( new EnumElement( "DISCONNECTED", 1 ) );
    $enum->add_element( new EnumElement( "CONNECTING", 2 ) );
    $enum->add_element( new EnumElement( "CONNECTED", 3 ) );

    my $obj = new Message( "Request3", "base::Request" );

    $obj->add_enum( $enum );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ) );
    $obj->add_member( new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ) );
    $obj->add_member( new Element( new UserDefined( "TimeRange24" ), "time_range" ) );
    $obj->add_member( new Element( new UserDefinedEnum( "State" ), "state" ) );

    $file->add_msg( $obj );
}

open WCPP_H, ">", "example.h";

print WCPP_H $file->to_cpp_decl() . "\n";

open WCPP_JSON_H, ">", "example_to_json.h";

print WCPP_JSON_H $file->to_cpp_to_json_decl() . "\n";

open WCPP_JSON_CPP, ">", "example_to_json.cpp";

print WCPP_JSON_CPP $file->to_cpp_to_json_impl() . "\n";
