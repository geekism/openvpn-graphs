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
	img {
		margin: auto;
		border-collapse: separate; 
		border:solid white 1px; 
		border-radius:9px; 
		-moz-border-radius:9px;
		padding-left: 1px;
		padding-right: 1px; 
		background: #fff;
		border: 0px solid #fff;
		white-space: pre-line;
		vertical-align: top;
	}
  </style>
  <script src="https://use.fontawesome.com/0c6b783fa5.js"></script>
  <link href="https://bootswatch.com/4/cyborg/bootstrap.css" rel="stylesheet">
</head>
<center>
	<a class="link" href="?trend=cpu">CPU </a><i class="fa fa-bar-chart fa-lg" aria-hidden="true"></i> -
        <a class="link" href="?trend=mem">Mem </a><i class="fa fa-bar-chart fa-lg" aria-hidden="true"></i>
END
;
foreach $graph (@graphs) { print "
	- <a class=\"link\" href=\"?trend=$graph\">$graph </a><i class=\"fa fa-bar-chart fa-lg\" aria-hidden=\"true\"></i>
"; }

print <<END
<br><br><a href="/"><span class='header'>$svrname $type $descr</span></a>
<br><br>
END
;

if ($name eq '') {
	print "Daily Graphs (5 minute averages and maximums)";
	print "<br>";
		print "<a href='?trend=cpu'><img src='cpu-day.png' ></a><br><br>\n";
		print "<a href='?trend=mem'><img src='mem-day.png' ></a><br><br>\n";
	foreach $graph (@graphs)
	{
		print "<a href='?trend=$graph'><img src='$graph-day.png' ></a><br><br>\n";
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
</center>
</body>
</html>
END
;
