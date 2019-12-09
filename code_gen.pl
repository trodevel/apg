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

sub parse_obj($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $name ) = @_;

    my $obj = new Object( $name );
    #$obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );

    for( ; $$i_ref < $size; $$i_ref++ )
    {

    my $line = @$array_ref[$$i_ref];

    if ( $line =~ /^obj_end/ )
    {
        print STDERR "DEBUG: obj_end\n";
        $$file_ref->add_obj( $obj );
        return;
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

        parse_obj( $array_ref, $file_ref, $size, \$i, $1 );
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
