#!/usr/bin/perl
my @graphs;
my ($name, $descr);
push (@graphs, "eth0","tun0","vpn-black");
my $svrname = $ENV{'SERVER_NAME'};

my @values = split(/&/, $ENV{'QUERY_STRING'});
foreach my $i (@values) {
	($varname, $mydata) = split(/=/, $i);
	if ($varname eq 'trend') { $name = $mydata; }
}

if ($name eq '') { $descr = "summary"; } else { $descr = "$name"; }

print "Content-type: text/html;\n\n";
print <<END
<html>
<head>
  <TITLE>$svrname network traffic :: $descr</TITLE>
  <META HTTP-EQUIV="Refresh" CONTENT="600">
  <META HTTP-EQUIV="Cache-Control" content="no-cache">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <style>
	body { topMargin: 5; align: center; background: #fff; color: #000; font-family: Tahoma, Arial, Helvetica, Sans-Serif; font-size: 0.900em; font-color: #000; }
	a { text-decoration: none; }
	a:hover { text-decoration: underline bold; }
	table { margin: auto; width: 70%; border-collapse: separate; border:solid white 1px; border-radius:9px; -moz-border-radius:9px; padding-left: 10px; padding-right: 10px; background: #242424; border: 1px solid #fff; white-space: pre-line; }
	td.main { color: #fff; background: #242424; font-size: 0.900em; padding-top: 3px; padding-bottom: 3px; white-space: pre-line; }
	td.main a { font-size: 0.900em; }
	td.main a:hover { color: #fff; font-weight: bold; }
	td { background: #242424; color: #fff; }
	tr.main td { padding-top: 2px; padding-bottom: 2px; vertical-align: top; padding-left: 10px; padding-right: 10px; white-space: pre-line; }
	pre { font-family: monospace; width: 100%; border: 1px dashed #454545; !important; }
	p { text-align: center; }

  </style>
</head>

<a href="javascript:history.go(-1)"><span class='header'>$svrname $type $descr</span></a>
<br><br>
END
;

if ($name eq '') {
	print "Daily Graphs (5 minute averages and maximums)";
	print "<br>";
		print "<a href='?trend=cpu'><img src='cpu-day.png' border='1'></a><br><br>\n";
		print "<a href='?trend=mem'><img src='mem-day.png' border='1'></a><br><br>\n";
	foreach $graph (@graphs)
	{
		print "<a href='?trend=$graph'><img src='$graph-day.png' border='1'></a><br><br>\n";
		print "<br>";
	}
} elsif ($name eq 'vpn') {
print <<END
        Daily Graph (5 minute averages and maximums)<br>
        <img src='$name-day.png'><br>
        Weekly Graph (30 minute averages and maximums)<br>
        <img src='$name-week.png'><br>
        Monthly Graph (2 hour averages and maximums)<br>
        <img src='$name-month.png'><br>
        Yearly Graph (12 hour averages and maximums)<br>
        <img src='$name-year.png'>

END
} elsif ($name eq 'memory') {
print <<END
        Daily Graph (5 minute averages and maximums)<br>
        <img src='$name-day.png'><br>
        Weekly Graph (30 minute averages and maximums)<br>
        <img src='$name-week.png'><br>
        Monthly Graph (2 hour averages and maximums)<br>
        <img src='$name-month.png'><br>
        Yearly Graph (12 hour averages and maximums)<br>
        <img src='$name-year.png'>
END
;
} elsif ($name eq 'cpu') {
print <<END
	Daily Graph (5 minute averages and maximums)<br>
	<img src='$name-day.png'><br>
	Weekly Graph (30 minute averages and maximums)<br>
	<img src='$name-week.png'><br>
	Monthly Graph (2 hour averages and maximums)<br>
	<img src='$name-month.png'><br>
	Yearly Graph (12 hour averages and maximums)<br>
	<img src='$name-year.png'>
END
;
} else {
print <<END
	Daily Graph (5 minute averages and maximums)<br>
	<img src='$name-day.png'><br>
	Weekly Graph (30 minute averages and maximums)<br>
	<img src='$name-week.png'><br>
	Monthly Graph (2 hour averages and maximums)<br>
	<img src='$name-month.png'><br>
	Yearly Graph (12 hour averages and maximums)<br>
	<img src='$name-year.png'>
END
;
}

print <<END
<br><br>
</body>
</html>
END
;
