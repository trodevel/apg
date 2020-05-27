#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - Validator.
#
# Copyright (C) 2020 Sergey Kolevatov
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

# 1.0 - 20526 - initial commit

###############################################

package Validator;

use strict;
use warnings;
use 5.010;

###############################################

sub validate__obj($$)
{
    my ( $file_ref, $obj ) = @_;
}

###############################################

sub validate__base_msgs($)
{
    my ( $file_ref ) = @_;

    validate__obj( $file_ref, $$file_ref->{base_msgs} );
}

###############################################

sub validate__msgs($)
{
    my ( $file_ref ) = @_;

    validate__obj( $file_ref, $$file_ref->{msgs} );
}

###############################################

sub validate_extern($)
{
    my ( $file_ref ) = @_;

    validate__base_msgs( $file_ref );

    validate__msgs( $file_ref );
}

###############################################

sub validate($)
{
    my ( $file_ref ) = @_;

    validate_extern( $file_ref );

}

###############################################

1;
