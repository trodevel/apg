#!/usr/bin/perl -w

#
# Automatic Protocol Generator - Code Gen.
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
# SKV 19c7

# 1.0 - 19c07 - initial commit

my $VER="1.0";

###############################################

use strict;
use warnings;
use 5.010;
use Getopt::Long;


use File_cpp;
#use File_cpp_json;


###############################################

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

###############################################

sub read_config_file($$$)
{
    my ( $filename, $array_ref, $line_num_ref ) = @_;

    unless( -e $filename )
    {
        print STDERR "ERROR: file $filename doesn't exist\n";
        exit;
    }

    print "reading file $filename ...\n";

    open RN, "<", $filename;

    my $lines = 0;

    while( <RN> )
    {
        chomp;
        $lines++;

        # skip empty lines
        s/^\s+//g; # no leading white spaces
        next unless length;

        my $line = trim( $_ );

        next if( $line =~ /^#/ );	# ignore comments

        push( @$array_ref,  $line );
        push( @$line_num_ref, $lines );

        #print "DEBUG: $lines: $line\n";
    }

    print "read $lines lines(s) from $filename\n";
}

###############################################

use constant REGEXP_POD    => '(bool|([u]*)int(8|16|32|64)|float|double|string)';
use constant REGEXP_BOOL   => 'bool';
use constant REGEXP_INT    => '([u]*)int(8|16|32|64)';
use constant REGEXP_FLOAT  => 'float';
use constant REGEXP_DOUBLE => 'double';
use constant REGEXP_STR    => 'string';
use constant REGEXP_VR => '(:\s*([\(\[])\s*([0-9\.]*)\s*,\s*([0-9\.]*)\s*([\)\]])|)';

###############################################

sub to_ValidRange($)
{
    my ( $line ) = @_;

    die "malformed valid range '$line'" if( $line !~ /${\REGEXP_VR}/ );

    my $open_bracket  = $2;
    my $from          = $3;
    my $to            = $4;
    my $close_bracket = $5;

    my $has_from = ( defined $from and $from ne '' ) ? 1 : 0;
    my $has_to   = ( defined $to and $to ne '' ) ? 1 : 0;

    $from     = ( $has_from ) ? $from + 0 : 0;
    $to       = ( $has_to ) ? $to + 0 : 0;

    my $is_inclusive_from = ( $has_from and $open_bracket eq '[' ) ? 1 : 0;
    my $is_inclusive_to   = ( $has_to and $close_bracket eq ']' ) ? 1 : 0;

    print STDERR "DEBUG: to_ValidRange: incl_from=$is_inclusive_from from=$from to=$to incl_to=$is_inclusive_to\n";

    my $res = new ValidRange( $has_from, $from, $is_inclusive_from, $has_to, $to, $is_inclusive_to );

    return $res;
}

###############################################

sub to_Boolean($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_BOOL}/ );

    my $res = new Boolean();

    return $res;
}

sub to_Integer($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_INT}/ );

    my $u = $1;
    my $bits = $2;

    print STDERR "DEBUG: to_Integer: u=$u bits=$bits\n";

    my $is_unsigned = ( defined $u and $u eq 'u' ) ? 1 : 0;
    $bits = $bits + 0;

    my $res = new Integer( $is_unsigned, $bits );

    return $res;
}

sub to_Float($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_FLOAT}/ );

    my $res = new Float( 0 );

    return $res;
}

sub to_Double($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_DOUBLE}/ );

    my $res = new Float( 1 );

    return $res;
}

sub to_String($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_STR}/ );

    my $res = new String();

    return $res;
}

###############################################

sub to_pod($)
{
    my ( $line ) = @_;

    if( $line =~ /^${\REGEXP_BOOL}/ )
    {
        return to_Boolean( $line );
    }
    elsif( $line =~ /^${\REGEXP_INT}/ )
    {
        return to_Integer( $line );
    }
    elsif( $line =~ /^${\REGEXP_FLOAT}/ )
    {
        return to_Float( $line );
    }
    elsif( $line =~ /^${\REGEXP_DOUBLE}/ )
    {
        return to_Double( $line );
    }
    elsif( $line =~ /^${\REGEXP_STR}/ )
    {
        return to_String( $line );
    }

    die "to_pod: unknown data type '$line'\n";
}

###############################################

sub is_string($)
{
    my ( $line ) = @_;

    return 1 if ( $line =~ /^${\REGEXP_STR}/ );

    return 0;
}

###############################################

sub parse_pod($$)
{
    my ( $parent_ref, $line ) = @_;

    die "parse_pod: malformed object $line" if( $line !~ /^${\REGEXP_POD}\s*([a-zA-Z0-9_]*)\s*${\REGEXP_VR}/ );

    my $dt_str  = $1;
    my $name    = $4;
    my $valid   = $5;

    print STDERR "DEBUG: parse_pod: dt_str=$dt_str name=$name valid='$valid'\n";

    my $dt = to_pod( $dt_str );

    my $valid_range = undef;

    if( defined $valid and $valid ne '' )
    {
        $valid_range = to_ValidRange( $valid );
    }

    my $is_array = is_string( $dt_str );

    $$parent_ref->add_member( new ElementExt( $dt, $name, $valid_range, $is_array ) );
}

###############################################

sub parse_obj($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "malformed object $line" if( $line !~ /obj ([a-zA-Z0-9_]*)/ );

    $$i_ref++;

    my $name = $1;

    my $obj = new Object( $name );

    for( ; $$i_ref < $size; $$i_ref++ )
    {
        #print STDERR "DEBUG: i=$$i_ref size=$size\n";

        my $line = @$array_ref[$$i_ref];

        if ( $line =~ /^obj_end/ )
        {
            print STDERR "DEBUG: obj_end\n";
            $$file_ref->add_obj( $obj );
            return;
        }
        elsif ( $line =~ /^${\REGEXP_POD} / )
        {
            print STDERR "DEBUG: pod\n";
            parse_pod( \$obj, $line );
        }
        else
        {
            die( "parse_obj: cannot parse line '$line'" );
        }
    }

    die( "incomplete object $name\n" );
}

###############################################

sub parse($$)
{
    my ( $array_ref, $file_ref ) = @_;

    my $size = scalar( @$array_ref );

    for( my $i = 0; $i < $size; $i++ )
    {
        my $line = @$array_ref[$i];

        #print STDERR "DEBUG: i=$i, line=$line\n";

        if ( $line =~ /protocol ([a-zA-Z0-9_]*)/ )
        {
            print STDERR "DEBUG: protocol $1\n";
            $$file_ref->set_name( $1 );
        }
        elsif ( $line =~ /base ([a-zA-Z0-9_]*)/ )
        {
            print STDERR "DEBUG: base protocol $1\n";
            $$file_ref->set_base_prot( $1 );
        }
        elsif ( $line =~ /include "([a-zA-Z0-9_\/\.\-]*)"/ )
        {
            print STDERR "DEBUG: include '$1'\n";
            $$file_ref->add_include( $1 );
        }
        elsif ( $line =~ /obj ([a-zA-Z0-9_]*)/ )
        {
            print STDERR "DEBUG: obj $1\n";

            parse_obj( $array_ref, $file_ref, $size, \$i, $line );
        }
        else
        {
            print STDERR "DEBUG: unknown line $line\n";
            next;
        }
    }

}

###############################################

sub print_help
{
    print STDERR "\nUsage: code_gen.sh --input_file <input.txt> --output_file <output.h>\n";
    print STDERR "\nExamples:\n";
    print STDERR "\ncode_gen.sh --input_file protocol.txt --output_file protocol.h\n";
    print STDERR "\n";
    exit
}

###############################################

my $input_file;
my $output_file;

my $verbose = 0;

GetOptions(
            "input_file=s"      => \$input_file,   # string
            "output_file=s"     => \$output_file,  # string
            "verbose"           => \$verbose   )   # flag
  or die("Error in command line arguments\n");

&print_help if not defined $input_file;
&print_help if not defined $output_file;

print STDERR "input_file  = $input_file\n";
print STDERR "output file = $output_file\n";

my @input = ();
my @line_num = ();

read_config_file( $input_file, \@input, \@line_num );

my $file = new File( "example" );

parse( \@input, \$file );

$file->set_use_ns( 0 );

open FO, ">", $output_file;

print FO $file->to_cpp_decl() . "\n";

###############################################
1;
