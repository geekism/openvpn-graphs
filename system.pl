#!/usr/bin/perl
use RRDs;
my $rrd = '/srv/beyondhd.me/';
my $img = '/srv/beyondhd.me/';
my $rrdtool = '/usr/bin/rrdtool';
my $debug = '1';
&ProcessInterface("eth0", "network");
&ProcessInterface("tun0", "OpenVPN");

sub ProcessInterface
{
	my $in = `/sbin/ifconfig $_[0]|/bin/grep "RX bytes"|cut -d':' -f2|/usr/bin/cut -d' ' -f1`;
	my $out = `/sbin/ifconfig $_[0] | /bin/grep "TX bytes"|cut -d':' -f3|/usr/bin/cut -d' ' -f1`;
	chomp($in);
	chomp($out);
	if ($debug eq "1") { print "$_[0] -> in: $in out: $out\n"; }
	if (! -e "$rrd/$_[0].rrd")
	{
		print "creating rrd database for $_[0] interface...\n";
		RRDs::create "$rrd/$_[0].rrd",
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
	RRDs::update "$rrd/$_[0].rrd",
		"-t", "in:out",
		"N:$in:$out";
	if ($ERROR = RRDs::error) { print "$0: unable to insert data into $rrd/$_[0].rrd: $ERROR\n"; }
	&CreateGraph($_[0], "day", $_[1]);
	&CreateGraph($_[0], "week", $_[1]);
	&CreateGraph($_[0], "month", $_[1]); 
	&CreateGraph($_[0], "year", $_[1]);
}

sub CreateGraph
{
#	  $_[1]: interval (ie, day, week, month, year)
#	  $_[2]: interface description 

	RRDs::graph "$img/$_[0]-$_[1].png",
		"-s -1$_[1]",
		"-t traffic on $_[0] :: $_[2]",
		"--lazy",
		"-h", "80", "-w", "600",
		"-l 0",
		"-a", "PNG",
		"-v bytes/sec",
		"--slope-mode",
		"--color", "BACK#ffffff",
		"--color", "CANVAS#ffffff",
		"--font", "LEGEND:7",
		"DEF:in=$rrd/$_[0].rrd:in:AVERAGE",
		"DEF:maxin=$rrd/$_[0].rrd:in:MAX",
		"DEF:out=$rrd/$_[0].rrd:out:AVERAGE",
		"DEF:maxout=$rrd/$_[0].rrd:out:MAX",
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
	if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] graph: $ERROR\n"; }
}

my $mem = `free -b |grep Mem`;
my $swap = `free -b |grep Swap |cut -c19-29 |sed 's/ //g'`;
my @mema = split(/\s+/, $mem);
my $buffers = $mema[5];
my $cached = $mema[6];
$mem = $mema[3] + $buffers + $cached;
chomp($swap);

if (! -e "$rrd/mem.rrd")
{
	print "creating rrd database for memory usage...\n";
	system("$rrdtool create $rrd/mem.rrd -s 300"
		." DS:mem:GAUGE:600:0:U"
		." DS:buf:GAUGE:600:0:U"
		." DS:cache:GAUGE:600:0:U"
		." DS:swap:GAUGE:600:0:U"
		." RRA:AVERAGE:0.5:1:576"
		." RRA:AVERAGE:0.5:6:672"
		." RRA:AVERAGE:0.5:24:732"
		." RRA:AVERAGE:0.5:144:1460");
}

`$rrdtool update $rrd/mem.rrd -t mem:buf:cache:swap N:$mem:$buffers:$cached:$swap`;

if ($debug eq "1") { print "memory -> free: $mem buffers: $buffers cached: $cached swap: $swap\n"; }

&CreateGraphMemory("day");
&CreateGraphMemory("week");
&CreateGraphMemory("month"); 
&CreateGraphMemory("year");

sub CreateGraphMemory
{

	system("$rrdtool graph $img/mem-$_[0].png"
		." -s \"-1$_[0]\""
		." -t \"memory usage over the last $_[0]\""
		." --lazy"
		." -h 80 -w 600"
		." -l 0"
		." -a PNG"
		." -v \"bytes\""
		." -b 1024"
		." DEF:mem=$rrd/mem.rrd:mem:AVERAGE"
		." DEF:buf=$rrd/mem.rrd:buf:AVERAGE"
		." DEF:cache=$rrd/mem.rrd:cache:AVERAGE"
		." DEF:swap=$rrd/mem.rrd:swap:AVERAGE"
		." CDEF:total=mem,swap,buf,cache,+,+,+"
		." CDEF:res=mem,buf,cache,+,+"
		." AREA:mem#FFCC66:\"Physical Memory Usage\""
		." STACK:buf#FF9999:\"Buffers\""
		." STACK:cache#FF0099:\"Cache\""
		." STACK:swap#FF9900:\"Swap Memory Usage\\n\""
		." GPRINT:mem:MAX:\"Residental  Max\\: %5.1lf %s\""
		." GPRINT:mem:AVERAGE:\" Avg\\: %5.1lf %s\""
		." GPRINT:mem:LAST:\" Current\\: %5.1lf %s\\n\""
		." GPRINT:buf:MAX:\"Buffers     Max\\: %5.1lf %s\""
		." GPRINT:buf:AVERAGE:\" Avg\\: %5.1lf %s\""
		." GPRINT:buf:LAST:\" Current\\: %5.1lf %s\\n\""
		." GPRINT:cache:MAX:\"Cache       Max\\: %5.1lf %s\""
		." GPRINT:cache:AVERAGE:\" Avg\\: %5.1lf %s\""
		." GPRINT:cache:LAST:\" Current\\: %5.1lf %s\\n\""
		." GPRINT:swap:MAX:\"Swap        Max\\: %5.1lf %s\""
		." GPRINT:swap:AVERAGE:\" Avg\\: %5.1lf %s\""
		." GPRINT:swap:LAST:\" Current\\: %5.1lf %s\\n\""
		." GPRINT:total:MAX:\"Total       Max\\: %5.1lf %s\""
		." GPRINT:total:AVERAGE:\" Avg\\: %5.1lf %s\""
		." GPRINT:total:LAST:\" Current\\: %5.1lf %s\\n\""
		." LINE1:res#CC9966"
		." LINE1:total#CC6600 > /dev/null");
}

updatecpudata();
updatecpugraph('day');
updatecpugraph('week');
updatecpugraph('month');
updatecpugraph('year');

sub updatecpugraph {
        my $period    = $_[0];

        RRDs::graph ("$img/cpu-$period.png",
                "--start", "-1$period", "-aPNG", "-i", "-z",
                "--alt-y-grid", "-w 600", "-h 80", "-l 0", "-r",
                "-t cpu usage per $period",
                "-v perecent",
                "DEF:user=$rrd/cpu.rrd:user:AVERAGE",
                "DEF:system=$rrd/cpu.rrd:system:AVERAGE",
                "DEF:idle=$rrd/cpu.rrd:idle:AVERAGE",
                "DEF:io=$rrd/cpu.rrd:io:AVERAGE",
                "DEF:irq=$rrd/cpu.rrd:irq:AVERAGE",
                "CDEF:total=user,system,idle,io,irq,+,+,+,+",
                "CDEF:userpct=100,user,total,/,*",
                "CDEF:systempct=100,system,total,/,*",
                "CDEF:iopct=100,io,total,/,*",
                "CDEF:irqpct=100,irq,total,/,*",
                "AREA:userpct#0000FF:user cpu usage\\j",
                "STACK:systempct#FF0000:system cpu usage\\j",
                "STACK:iopct#FFFF00:iowait cpu usage\\j",
                "STACK:irqpct#00FFFF:irq cpu usage\\j",
                "GPRINT:userpct:MAX:maximal user cpu\\:%3.2lf%%",
                "GPRINT:userpct:AVERAGE:average user cpu\\:%3.2lf%%",
                "GPRINT:userpct:LAST:current user cpu\\:%3.2lf%%\\j",
                "GPRINT:systempct:MAX:maximal system cpu\\:%3.2lf%%",
                "GPRINT:systempct:AVERAGE:average system cpu\\:%3.2lf%%",
                "GPRINT:systempct:LAST:current system cpu\\:%3.2lf%%\\j",
                "GPRINT:iopct:MAX:maximal iowait cpu\\:%3.2lf%%",
                "GPRINT:iopct:AVERAGE:average iowait cpu\\:%3.2lf%%",
                "GPRINT:iopct:LAST:current iowait cpu\\:%3.2lf%%\\j",
                "GPRINT:irqpct:MAX:maximal irq cpu\\:%3.2lf%%",
                "GPRINT:irqpct:AVERAGE:average irq cpu\\:%3.2lf%%",
                "GPRINT:irqpct:LAST:current irq cpu\\:%3.2lf%%\\j");
        $ERROR = RRDs::error;
        print "Error in RRD::graph for cpu: $ERROR\n" if $ERROR;
}

sub updatecpudata {
        if ( ! -e "$rrd/cpu.rrd") {
                print "Creating cpu.rrd";
                RRDs::create ("$rrd/cpu.rrd", "--step=60",
                        "DS:user:COUNTER:600:0:U",
                        "DS:system:COUNTER:600:0:U",
                        "DS:idle:COUNTER:600:0:U",
                        "DS:io:COUNTER:600:0:U",
                        "DS:irq:COUNTER:600:0:U",
                        "RRA:AVERAGE:0.5:1:576",
                        "RRA:AVERAGE:0.5:6:672",
                        "RRA:AVERAGE:0.5:24:732",
                        "RRA:AVERAGE:0.5:144:1460");
                $ERROR = RRDs::error;
                print "Error in RRD::create for cpu: $ERROR\n" if $ERROR;
        }

        my ($cpu, $user, $nice, $system, $idle, $io, $irq, $softirq);

        open STAT, "/proc/stat";
        while(<STAT>) {
                chomp;
                /^cpu\s/ or next;
                ($cpu, $user, $nice, $system, $idle, $io, $irq, $softirq) = split /\s+/;
                last;
        }
        close STAT;
        $user += $nice;
        $irq  += $softirq;

        RRDs::update ("$rrd/cpu.rrd",
                "-t", "user:system:idle:io:irq", 
                "N:$user:$system:$idle:$io:$irq");
        $ERROR = RRDs::error;
        print "Error in RRD::update for cpu: $ERROR\n" if $ERROR;

        if ($debug eq "1") {  print "cpu -> user: $user system: $system idle: $idle iowait: $io irq: $irq\n"; }
}


