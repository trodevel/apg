#!/usr/bin/perl -w

# C++ code generation tools
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

# $Revision: 12963 $ $Date:: 2020-05-05 #$ $Author: serge $
# 1.0   - 16b14 - initial version

package gtcpp;

require "gen_tools.pl";

############################################################
sub ifndef_define
{
    my ( $guard, $body ) = @_;

    my $guard_h = "${guard}_H";
    my $res =
"#ifndef $guard_h\n" .
"#define $guard_h\n\n" .
$body .
"#endif // $guard_h\n" ;

    return $res;
}
############################################################
sub namespacize
{
    my ( $name, $body ) = @_;

    my $res =
"namespace $name\n" .
"{\n\n" .
$body .
"} // namespace $name\n\n" ;

    return $res;
}
############################################################
sub ifndef_define_prot
{
    my ( $protocol_name, $file_name, $body ) = @_;

    my $guard = uc "APG_${protocol_name}__${file_name}";

    return ifndef_define( $guard, $body );
}
############################################################
sub array_to_decl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_decl() . "\n";
    }

    return $res;
}
############################################################

sub extract_namespace_and_object_name($)
{
    my( $complex_name ) = @_;

    my @temp = split /::/, $complex_name;

    my $size = scalar @temp;

#    ::p @temp;     # DEBUG

    die "invalid complex_name $complex_name" if ( $size == 0 ) ;

    my $namespace = "";
    my $name = "";

    if( $size == 1 )
    {
        $name = $temp[0];
    }
    elsif( $size == 2 )
    {
        $namespace  = $temp[0];
        $name       = $temp[1];
    }
    else
    {
        die "too complex name $complex_name";
    }

    return ( $namespace, $name );
}

############################################################

sub to_function_call_with_namespace($$)
{
    my( $complex_name, $function_name ) = @_;

    my $res = "";

    my ( $namespace, $name ) = extract_namespace_and_object_name( $complex_name );

    if( $namespace ne '' )
    {
        $res = "::" . $namespace . "::" . $function_name;
    }
    else
    {
        $res = $function_name;
    }

    return $res;
}

############################################################

############################################################
sub array_to_cpp_to_json_decl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_to_json_decl() . "\n";
    }

    return $res;
}
############################################################
sub array_to_string_decl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_to_string_decl() . "\n";
    }

    return $res;
}
############################################################
sub array_to_cpp_to_json_impl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_to_json_impl() . "\n";
    }

    return $res;
}
############################################################
sub to_include($$)
{
    my( $name, $is_system ) = @_;

    return ( $is_system == 0 ) ? '#include "'.  $name . '.h"' : '#include <'.  $name . '>';
}
############################################################
sub to_include_to_json
{
    my( $name ) = @_;

    return '#include "'.  $name . '_to_json.h"';
}
############################################################
sub array_to_include($$)
{
    my( $array_ref, $is_system ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . to_include(  $_, $is_system ) . "\n";
    }

    return $res;
}
############################################################
sub array_to_include_ext($)
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . to_include(  $_ . '/protocol', 0 ) . "\n";
    }

    return $res;
}
############################################################
sub array_to_include_to_json
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . to_include_to_json(  $_ ) . "\n";
    }

    return $res;
}
############################################################
sub base_class_to_json
{
    my( $base ) = @_;

    return "to_json( static_cast< const " . $base . " & >( o ) )";
}
############################################################

1;
