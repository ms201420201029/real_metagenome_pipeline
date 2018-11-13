#!/usr/bin/perl
print "usage:\ncdhit input output pieces\n" and exit unless scalar @ARGV == 3;
system("perl /data_center_03/USER/zhongwd/soft/cd-hit-v4.5.7-2011-12-16/cd-hit-para.v3.pl -i $ARGV[0] -o $ARGV[1] --Q $ARGV[2] --T SGE --S $ARGV[2] --P cd-hit-est -G 0 -n 8 -aS 0.9 -c 0.95 -M 0 -g 1 -q all.q --l vf=3g -r 0 -d 0 -T 3")
