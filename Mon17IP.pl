#!/usr/bin/env perl
#
# name     : Mon17IP.pl
# author   : Guo Xiang <gx2008758@gmail.com>(<perlbox.guo@gmail.com>)
# license  : GPL
# created  : 2015-11-15
# modified : 2015-11-18
# 

use strict;
use warnings;
use Socket;
use Encode;
use utf8;


binmode(STDOUT, ':encoding(utf8)');
open(FILE, "./17monipdb.dat");
my $buff = do {local $/; <FILE>;};
my $data_offset=hex(unpack('H8',$buff));
my @buff_t= map { sprintf '%02x', ord($_) } split //, $buff;


sub find {
    my ($ip)=@_;
    my $nip=unpack "N", inet_aton($ip);
    my $fip=int($nip/(256**3));
    my $fip_offset =$fip * 4 + 4;
    my $count=hex($buff_t[$fip_offset+3].$buff_t[$fip_offset+2].$buff_t[$fip_offset+1].$buff_t[$fip_offset])*8;
    my $offset=$count+1028;

    my $start=0;
    my $end=int(($data_offset - $offset)/8);
    while($start <= $end){
            my $middle=int(($start+$end)/2);
            my $mid_offset=$offset+ 8 * $middle;
            my $mid_val=hex($buff_t[$mid_offset].$buff_t[$mid_offset+1].$buff_t[$mid_offset+2].$buff_t[$mid_offset+3]);
            if($nip>$mid_val){
                  $start=$middle+1;
            }elsif ($nip<$mid_val){
                 $end=$middle-1;
            }
            else {last;} 
    }
    $offset = $offset + 8 * $start;
    if($offset == $data_offset)
    {
        print "Error\n";
        return undef;
    }

    my $data_pos=hex($buff_t[$offset+6].$buff_t[$offset+5].$buff_t[$offset+4]);
    my $data_length=hex($buff_t[$offset+7]);
    $offset = $data_offset + $data_pos - 1024 ;  #why 1024?
    my $value = join('', @buff_t[$offset .. $offset + $data_length-1]);
    #$value = pack('H*',$value);  
    #$value=decode('utf-8',$value);
    $value=decode('utf-8',pack('H*',$value));
    chop($value);
    return $value;


} 

#test case!
my $r=find("58.247.122.86");print $r."\n";
$r=find("10.12.7.242");print $r."\n";
$r=find("127.0.0.1");print $r."\n";
$r=find("www.baidu.com");print $r."\n";

