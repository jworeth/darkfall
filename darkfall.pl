#!/usr/bin/perl
use warnings;
use IO::Socket;
use POSIX  'setsid';
my $cmd = $ARGV[0] || ''; 
our $pidfile = "/var/run/$0.pid";
my $pid = check_status(); 
if ($cmd =~ /help/i) { print <<EOF
$0 [command]
possible commands are: 
    help this
    start start script. Will check if started.
    stop stop script.
    status output status (work | stop)
EOF
} elsif ($cmd =~ /stop/i) {
    print "Darkfall Monitor Script is not working\n", exit unless $pid;
    kill 9, -$pid or die $!;
    unlink $pidfile or die $!;
    print "Killed pid $pid\n";
    exit;
} elsif ($cmd =~ /status/i) {
    print $pid ? "Darkfall Monitor Working with pid $pid\n" : "Stopped\n";
    exit;
}
print("Darkfall Monitor already work with pid $pid\n"), exit if $pid;

#let's daemonize
open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
exit if fork; 
setsid or die "Can't start a new session: $!";
open my $f, '>', $pidfile or die $!;
print $f "$$";
close $f;

#tell OS to clean up dead children
$SIG{CHLD} = 'IGNORE';

#Look checking PHP script
while(1){
	system("php -q /home/vudoo/public_html/proximity/warningsystem.php");
sleep(15);
 }

sub check_status {
    my $pid = 0;
    if (-e $pidfile) {
 open my $f, $pidfile or die $!;
        $pid = <$f>;
        unless ($pid =~ /\d+/ and kill(0, $pid)) {  
    print "Wrong pid file $pidfile. Removing\n";
    unlink $pidfile or die $!;
    $pid = 0;
        }
    }
    return $pid;
}
