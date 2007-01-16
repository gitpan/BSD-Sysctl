# 03-iterator.t
# Basic sanity checks for BSD::Sysctl
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 12;

use BSD::Sysctl;

my $it = BSD::Sysctl->iterator('kern.ipc');
ok( defined($it), 'defined a BSD::Sysctl iterator' );

my $sysctl_binary;
for my $path (qw( /sbin /bin /usr/sbin/ /usr/bin /usr/local/sbin /usr/local/bin )) {
    my $binary = "$path/sysctl";
    if (-x $binary) {
        $sysctl_binary = $binary;
        last;
    }
}

SKIP: {
    skip( 'failed to find sysctl binary', 4 )
        unless defined $sysctl_binary;

    my @sysctl = `$sysctl_binary -Na kern.ipc`;
    my $x = $it->next;
    my $first = shift @sysctl;
    chomp $first;
    is( $first, $x, 'iterate kern.ipc' ) or do {
        diag( "bin: " . join( ' ', map{ord} split //, $first));
        diag( " xs: " . join( ' ', map{ord} split //, $x));
    };
    my $count;
    ++$count while $it->next;
    is( $count, scalar(@sysctl), 'number of elements in subtree' );

    $x = $it->reset->next;
    is( $first, $x, 'reset kern.ipc' ) or do {
        diag( "bin: " . join( ' ', map{ord} split //, $first));
        diag( " xs: " . join( ' ', map{ord} split //, $x));
    };

    ($first) = `$sysctl_binary -Na`;
    chomp $first;

    $it = BSD::Sysctl->iterator;
    $x  = $it->next;
    is( $first, $x, 'iterate implicit' ) or do {
        diag( "bin: " . join( ' ', map{ord} split //, $first));
        diag( " xs: " . join( ' ', map{ord} split //, $x));
    };
}

{
    my $iter = BSD::Sysctl->iterator('vfs');
    ok( !defined($iter->name), 'no name before next' );
    ok( !defined($iter->value), 'no value before next' );

    my $first = $iter->next;
    is( $iter->name, $first, 'name of first iterator' );
    ok( defined($iter->value), 'value of first' );

    my $next = $iter->next;
    is( $iter->name, $next, 'name of next iterator' );
    isnt( $first, $next, 'next is different' );
    ok( defined($iter->value), 'value of next' );
}
