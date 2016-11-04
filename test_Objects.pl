#!/usr/bin/perl -w

# $Revision: 4901 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

my $VER="1.0";

use strict;
use warnings;
use Objects;

{
    my @members = ( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    my $obj = new Object( "SomeObject",  \@members  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 )
         );
    my $obj = new Object( "AnotherObject",  \@members  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
         );
    my $obj = new Message( "Request",  \@members, undef  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
         );
    my $obj = new Message( "Request",  \@members, "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ),
        new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef )
         );
    my $obj = new Message( "Request2",  \@members, "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
