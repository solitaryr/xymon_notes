#!/usr/bin/perl

#############################################
# Name: bbnote_editor.cgi
# Xymon update: Galen Johnson
# Original Author: Chris Naude
# Purpose: Manage HTML notes files
# Version: 1.0
# The text2html module can be downloaded from CPAN
#############################################

use strict;
use CGI ":standard";
use HTML::FromText;

# Your $BBHOME
my $bb_home = "/usr/local/hobbit/server";
# hobbit config file
my $hobbitcfg="/usr/local/hobbit/server/etc/hobbitserver.cfg";
# The web path to gifs.
my $bb_gifs = "/hobbit/gifs";
# The main web path for bb display.
my $bb_web  = "/hobbit/";

# The actual www notes dir on the server
my $bb_notes  = "$bb_home/www/notes";
# This is where the data files are stored.
# Not to be confused with the default notes dir.
my $bb_notesdata  = "$bb_home/etc/notesdata";
my $bb_header = "$bb_home/web/notes_header"; # Change this if needed.
my $bb_footer = "$bb_home/web/notes_footer"; # Change this if needed.
#Standard bb-hosts file
my $bb_hosts = "$bb_home/etc/bb-hosts";
my $bb_showhosts = "$bb_home/bin/bbhostshow";

# No changes needed below.
my $color = "blue";
my %hosts;
my $cmd = param("cmd");
my $host = param("host");
$host =~ s/(.*?)\///g;
$host =~ s/(\.html)$//g;
my $note = param("note");
my @lines;

# Set up the environment variables and dynamic variables from hobbitserver.cfg
foreach (`. $hobbitcfg; set`) {
    chomp;
    my ($var,$val) = /^\s*(.*?)\s*=\s*(.*)/;
    $ENV{$var}  = $val;
}

sub print_notesdata {
    open (NOTESDATA, "<$bb_notesdata/${host}") or &print_error("I can't read from $bb_notesdata/$host!");
    while (<NOTESDATA>) {
        print;
    }
    close NOTESDATA;
}

sub write_notesdata {
    open (NOTESDATA, ">$bb_notesdata/$host") or &print_error("I can't write to $bb_notesdata/$host!");
    print NOTESDATA $note;
    close NOTESDATA;
}

sub make_note {
    my ($color) = @_;
    my $note = "$bb_notes/${host}.html";

    open (NOTE, ">$note") or &print_error("I can't open $note for writing!");
    select NOTE;
    &print_header($color);
    &print_notesdata;
    &print_footer($color);
    select STDOUT;
    close NOTE;

}

sub save_note {
    &write_notesdata;
    &make_note('blue');
    &get_note;
    print '<center><b><font color="white">Note saved.</font></b></center><p>';
    &print_note;
}

sub edit_note {
    if ($cmd =~ /add html/) {
        my $t2h = HTML::FromText->new({
            blockcode  => 1,
            lines      => 1,
            tables     => 1,
            bullets    => 1,
            numbers    => 1,
            urls       => 1,
            email      => 1,
            bold       => 1,
            underline  => 1,
        });
        $note = $t2h->parse( $note );
        #$note =~ s/\n/<br>/sgi; #

    }
    if ($cmd =~ /strip html/) {
        $note =~ s/<.*?>//sgi;
    }
    print <<HTML;
<CENTER><TABLE BORDER="1" CELLPADDING="3><CAPTION><H2><CENTER>$host [$hosts{$host}]</CENTER></H2></CAPTION>
<TR><TD ALIGN="CENTER"><form method="POST"><input type="hidden" name="host" value="$host">
<TEXTAREA ROWS="35" COLS="80" NAME="note" STYLE="background-color:#000066;color:dddddd">
HTML
if ($note) {
    print $note;
} elsif ($lines[0]) {
    print @lines;
} else {
    print '<!-- Remember to use proper HTML formatting here. -->';
}
    print <<HTML;
</TEXTAREA><br>
<input name="cmd" value="preview" type="submit">
<input name="cmd" value="add html tags" type="submit">
<input name="cmd" value="strip html tags" type="submit">
<input name="cmd" value="cancel" type="submit"></form></TD></TR></TABLE></CENTER>
HTML
}

sub print_note {
    print <<HTML;
<CENTER><TABLE WIDTH="75%" BORDER="1" CELLPADDING="3"><CAPTION><CENTER><H2>$host [$hosts{$host}]</H2></CENTER></CAPTION><TR><TD>
HTML
    if ($lines[0]) {
        print @lines;
        print <<HTML;
</TD></TR><TR><TD ALIGN="CENTER"><form method="POST"><input type="hidden" name="host" value="$host">
HTML
    } elsif ($cmd =~ /preview/) {
        print <<HTML;
$note</TD></TR><TR><TD ALIGN="CENTER"><form method="POST"><input type="hidden" name="host" value="$host">
<input name="cmd" value="save" type="submit">
HTML
    } else {
        print <<HTML;
The are no notes for $host [$hosts{$host}].</TD></TR>
<TR><TD ALIGN="CENTER"><form method="POST"><input type="hidden" name="host" value="$host">
HTML
}
    print <<HTML;
<input type="hidden" name="note" value='$note'>
<input name="cmd" value="edit" type="submit">
<input name="cmd" value="list" type="submit"></form></TD></TR></TABLE></CENTER>
HTML
}

sub print_error {
    my $error = shift;
    print "<center><b><font color=\"red\">$error</font></b></center><p>";
}

sub get_note {
    if ( -s "$bb_notesdata/$host") {
        open (NOTE, "<$bb_notesdata/$host") or &print_error("I can't open $bb_notesdata/$host for reading!");
        while (my $note = <NOTE>) {
            push @lines, $note;
        }
        close NOTE;
    }
}

sub print_menu{
    print '<CENTER><TABLE BORDER="1" CELLPADDING="3"><CAPTION><H2><CENTER>Xymon Notes</CENTER></H2><b></b></CAPTION>';
    for my $host(sort keys %hosts) {
        print <<HTML;
<TR><TD>$host</TD><TD>$hosts{$host}</TD>
<TD><form method="POST"><input type="hidden" name="host" value="$host">
<input name="cmd" value="view" type="submit">
<input name="cmd" value="edit" type="submit"></form></TD></TR>
HTML
    }
    print '</TABLE></CENTER>';
}

sub get_hosts{
    open (HOSTS, "-|", $bb_showhosts, $bb_hosts) or &print_error("I can't open $bb_hosts!");
    while (<HOSTS>) {
        if (/^(\d+\.\d+\.\d+\.\d+)\s+(.*?)\s+/) {
            $hosts{$2} = $1;
        }
    }
    close HOSTS;
}

sub print_header {
    my $color = shift;
    print "Content-type: text/html; charset=iso-8859-1\n\n";
    open (HEAD, "<$bb_header") or &print_error("I can't open $bb_header for reading!");
    while (<HEAD>) {
       # It's a bit hard to edit with a refresh ;)
        if (/META/i && /HTTP-EQUIV/i && /REFRESH/i && /CONTENT/i) { s/<(.*?)>/<!-- Refresh removed -->/g; }
        s/&HOBBITLOGO/$ENV{'HOBBITLOGO'}/g;
        s/&BBBACKGROUND/$color/g;
        s/&BBMENUSKIN/$ENV{'BBMENUSKIN'}/g;
        s/&BBPAGEPATH/$ENV{'BBPAGEPATH'}/g;
        s/&BBSKIN/$ENV{'BBSKIN'}/g;
        s/&BBDATE/$ENV{'BBDATE'}/g;
        print;
    }
    close HEAD;
}

sub print_footer{
    open (FOOT, "<$bb_footer") or &print_error("I can't open $bb_footer for reading!");
    while (<FOOT>) {
        s/&BBMENUSKIN/$ENV{'BBMENUSKIN'}/g;
        s/&HOBBITDREL/$ENV{'HOBBITDREL'}/g;
        print;
    }
    close FOOT;
}

# Main
my ($oldbar) = $|;
my $cfh = select (STDOUT);
$| = 1;

&get_hosts;
&print_header($color); # I like blue ;)
if ($cmd =~ /edit|html/) {
    &get_note;
    &edit_note;
} elsif ($cmd eq 'view') {
    &get_note;
    &print_note;
} elsif ($cmd eq 'preview') {
    &print_note;
} elsif ($cmd eq 'preview as html') {
    &print_note;
} elsif ($cmd eq 'save') {
    &save_note;
} else {
    &print_menu;
}

&print_footer;

$| = $oldbar;
 select ($cfh);
