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

use Scalar::Util qw(blessed);        # blessed

require File;
require Objects_php;
require "gen_tools_php.pl";

###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_html_helper_php__to_enum__body__init_members__body($$)
{
    my ( $enum_name, $name ) = @_;

    return "${enum_name}__${name} => '$name',";
}

sub generate_html_helper_php__to_enum__body__init_members($)
{
    my ( $enum ) = @_;

    my $res = "";

    foreach( @{ $enum->{elements} } )
    {
        $res .= generate_html_helper_php__to_enum__body__init_members__body( $enum->{name}, $_->{name} ) . "\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}


sub generate_html_helper_php__to_enum__body_1($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function to_html_header__${name}( \$r )\n" .
"{\n" .
"    return array( '" . uc( ${name} ) . "' );\n".
"}\n";

    return $res;
}

sub generate_html_helper_php__to_enum__body_2($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function to_html__${name}( \$r )\n" .
"{\n" .
"    return to_string__${name}( \$r ) . \" (\" . \$r . \")\";\n".
"}\n";

    return $res;
}

sub generate_html_helper_php__to_enum__body($$)
{
    my ( $namespace, $enum ) = @_;

    my $res =

        generate_html_helper_php__to_enum__body_1( $namespace, $enum ) . "\n" .
        generate_html_helper_php__to_enum__body_2( $namespace, $enum );

    return $res;
}

sub generate_html_helper_php__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_html_helper_php__to_enum__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_html_helper_php__to_object__body__init_headers__body($)
{
    my ( $obj ) = @_;

    my $res        = "'" . uc( $obj->{name} ) . "'";

    return $res;
}

sub generate_html_helper_php__to_object__body__init_headers($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        if( $res ne '' )
        {
            $res .= ", ";
        }

        $res .= generate_html_helper_php__to_object__body__init_headers__body( $_ );
    }

    return $res;
}

sub generate_html_helper_php__to_object__body__init_members__body($$)
{
    my ( $obj, $namespace ) = @_;

    my $res;

    my $name        = $obj->{name};

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = $obj->{data_type}->to_php__to_html_func_name() . "( \$r->${name}, '" . $obj->{data_type}->{value_type}->to_php__to_html_func_name( $namespace ) . "' )";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = $obj->{data_type}->to_php__to_html_func_name() .
            "( \$r->${name}, '" .
            $obj->{data_type}->{key_type}->to_php__to_html_func_name( $namespace ) . "', '" .
            $obj->{data_type}->{mapped_type}->to_php__to_html_func_name( $namespace ) . "' )";
    }
    else
    {
        $res = $obj->{data_type}->to_php__to_html_func_name( undef ) . "( \$r->${name} )";
    }

    return $res;
}

sub generate_html_helper_php__to_object__body__init_members($$)
{
    my ( $msg, $namespace ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        if( $res ne '' )
        {
            $res .= ",\n";
        }
        else
        {
            $res .= "\n";
        }

        $res .= generate_html_helper_php__to_object__body__init_members__body( $_, $namespace );
    }

    return $res;
}

sub generate_html_helper_php__to_object__body($$$$$)
{
    my ( $namespace, $msg, $is_message, $is_base_msg, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"function to_html__${name}( & \$r )\n" .
"{\n";

    $res .= "    \$header = array( ";

    my $headers = generate_html_helper_php__to_object__body__init_headers( $msg );

    if( $is_message || $is_base_msg )
    {
        if( $msg->has_base_class() )
        {
            my $base_header = "'" . $msg->get_base_class() . "'";

            if( $headers ne '' )
            {
                $headers = $base_header . ", " . $headers;
            }
            else
            {
                $headers = $base_header;
            }
        }
        else
        {
        }
    }

    $res .= $headers . " );\n\n";

    $res .= "    \$data = array(";

    my $data = generate_html_helper_php__to_object__body__init_members( $msg, $namespace );

    if( $is_message || $is_base_msg )
    {
        if( $msg->has_base_class() )
        {
            my $base_data = "\n" . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "to_html_" ). "( \$r )";

            if( $data ne '' )
            {
                $data = $base_data . "," . $data;
            }
            else
            {
                $data = $base_data;
            }
        }
        else
        {
        }
    }

    $res .= main::tabulate( main::tabulate( $data ) );

    $res .= "        );\n\n";

    $res .=
"    \$res = \\basic_parser\\to_html_table( \$header, \$data );\n" .
"\n" .
"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_html_helper_php__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_html_helper_php__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $is_base_msg, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_html_helper_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_html_helper_php__to_object__core( $file_ref,  $$file_ref->{objs}, 0, 0 );
}

sub generate_html_helper_php__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_html_helper_php__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_html_helper_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_html_helper_php__to_object__core( $file_ref,  $$file_ref->{msgs}, 1, 0 );
}

sub generate_html_helper_php__write__body($$)
{
    my ( $namespace, $name ) = @_;

    return "'$namespace\\$name'         => 'to_html__${name}'";
}

sub generate_html_helper_php__write($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $namespace = get_namespace_name( $$file_ref );

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_html_helper_php__write__body( $namespace, $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_html_helper_php__write_objs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_html_helper_php__write( $file_ref, $$file_ref->{objs} );

    return $res;
}

sub generate_html_helper_php__write_msgs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_html_helper_php__write( $file_ref, $$file_ref->{msgs} );

    return $res;
}

sub generate_html_helper_php__to_html($)
{
    my ( $file_ref ) = @_;

    my $res =
"function to_html( \$obj )\n" .
"{\n" .
"    \$handler_map = array(\n" .
"        // objects\n".
    generate_html_helper_php__write_objs( $file_ref ) .
"        // messages\n".
    generate_html_helper_php__write_msgs( $file_ref ) .
"    );\n" .
"\n" .
"    \$type = get_class( \$obj );\n" .
"\n" .
"    if( array_key_exists( \$type, \$handler_map ) )\n" .
"    {\n" .
"        \$func = '\\\\" . get_namespace_name( $$file_ref ) . "\\\\' . \$handler_map[ \$type ];\n" .
"        return \$func( \$obj );\n" .
"    }\n" .
"\n" .
"    return " . ( $$file_ref->has_base_prot() ? ( "\\". $$file_ref->{base_prot} . "\\to_html( \$obj )" ) : "NULL" ) . ";\n" .
"}\n" .
"\n";

    return $res;
}

sub generate_html_helper_php__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/html_helper" );
    }

    return @res;
}

sub generate_html_helper_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_html_helper_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_html_helper_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_html_helper_php__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_html_helper_php__to_message( $file_ref ) .
"// generic\n" .
"\n" .
    generate_html_helper_php__to_html( $file_ref )
;

    my @own_includes;

    push( @own_includes, "str_helper" );

    my @includes;

    push( @includes, generate_html_helper_php__to_includes( $file_ref ) );

    push( @includes, "basic_parser/html_helper" );

    my $res = to_body( $$file_ref, $body, get_namespace_name( $$file_ref ),  "html_helper", \@own_includes, \@includes );

    return $res;
}

###############################################

1;
