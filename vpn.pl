#!/usr/bin/perl
use RRDs;
my $rrd = '/srv/beyondhd.me/';
my $img = '/srv/beyondhd.me/';
my $rrdtool = '/usr/bin/rrdtool';
my $debug = '1';
my $name = $ARGV[0];
my $INVAL = $name."_IN";
my $OUTVAL = $name."_OUT";
my $in = `/sbin/iptables -v -x -L $INVAL|/bin/grep -E "10"|/usr/bin/cut -d' ' -f5`;
my $out = `/sbin/iptables -v -x -L $OUTVAL|/bin/grep -E "RETURN"|/usr/bin/cut -d' ' -f5`;

&ProcessVPNInterface($name, $in, $out);
sub ProcessVPNInterface
{
	chomp($in);
	chomp($out);
	if ($debug eq "1") { print "$_[0] -> in: $in out: $out\n"; }
	if (! -e "$rrd/vpn-$_[0].rrd")
	{
		print "creating rrd database for $_[0] interface...\n";
		RRDs::create "$rrd/vpn-$_[0].rrd",
			"-s", "300",
			"DS:in:DERIVE:600:0:U",
			"DS:out:DERIVE:600:0:U",
			"RRA:AVERAGE:0.5:1:576",
			"RRA:MAX:0.5:1:576",
			"RRA:AVERAGE:0.5:6:672",
			"RRA:MAX:0.5:6:672",
			"RRA:AVERAGE:0.5:24:732",
			"RRA:MAX:0.5:24:732",
			"RRA:AVERAGE:0.5:144:1460",
			"RRA:MAX:0.5:144:1460";
		if ($ERROR = RRDs::error) { print "$0: unable to create $rrd/$_[0].rrd: $ERROR\n"; }
	}
	RRDs::update "$rrd/vpn-$_[0].rrd",
		"-t", "in:out",
		"N:$in:$out";
	if ($ERROR = RRDs::error) { print "$0: unable to insert data into $rrd/vpn-$_[0].rrd: $ERROR\n"; }
	&CreateVPNGraph($_[0], "day", $_[1]);
	&CreateVPNGraph($_[0], "week", $_[1]);
	&CreateVPNGraph($_[0], "month", $_[1]); 
	&CreateVPNGraph($_[0], "year", $_[1]);
}

sub CreateVPNGraph
{
#	  $_[1]: interval (ie, day, week, month, year)
#	  $_[2]: interface description 
	RRDs::graph "$img/vpn-$_[0]-$_[1].png",
		"-s -1$_[1]",
		"-t traffic on vpn-$_[0] :: $_[1]",
		"--lazy",
		"-h", "80", "-w", "600",
		"-l 0",
		"-a", "PNG",
		"-v bytes/sec",
		"--slope-mode",
		"--color", "BACK#ffffff",
		"--color", "CANVAS#ffffff",
		"--font", "LEGEND:7",
		"DEF:in=$rrd/vpn-$_[0].rrd:in:AVERAGE",
		"DEF:maxin=$rrd/vpn-$_[0].rrd:in:MAX",
		"DEF:out=$rrd/vpn-$_[0].rrd:out:AVERAGE",
		"DEF:maxout=$rrd/vpn-$_[0].rrd:out:MAX",
		"CDEF:out_neg=out,-1,*",
		"CDEF:maxout_neg=maxout,-1,*",
		"AREA:in#32CD32:Incoming",
		"LINE1:maxin#336600",
		"GPRINT:in:MAX:  Max\\: %6.1lf %s",
		"GPRINT:in:AVERAGE: Avg\\: %6.1lf %S",
		"GPRINT:in:LAST: Current\\: %6.1lf %SBytes/sec\\n",
		"AREA:out_neg#4169E1:Outgoing",
		"LINE1:maxout_neg#0033CC",
		"GPRINT:maxout:MAX:  Max\\: %6.1lf %S",
		"GPRINT:out:AVERAGE: Avg\\: %6.1lf %S",
		"GPRINT:out:LAST: Current\\: %6.1lf %SBytes/sec\\n",
		"HRULE:0#000000";
	if ($ERROR = RRDs::error) { print "$0: unable to generate vpn-$_[0] graph: $ERROR\n"; }
}
