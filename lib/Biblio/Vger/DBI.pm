package Biblio::Vger::DBI;

use strict;
use warnings;

use DBI;
use File::Glob qw(glob);

use vars qw($root $database);

my %default_options = (
    'RaiseError' => 1,
    'FetchHashKeyName' => 'NAME_lc',
);

sub import {
    my $cls = shift;
    unshift @_, 'database' if @_ == 1;
    my %arg = @_;
    $root     = $arg{'root'} || $ENV{'VOYAGER'} || '/m1/voyager';
    $database = $arg{'database'} || $ENV{'DATABASE'};
}

sub connect {
    my $cls = shift;
    unshift @_, 'database' if @_ % 2;
    my %arg = @_;
    my %conf;
    my ($config_file) = glob($arg{'config_file'} || '~/.vgerdbirc');
    if (defined $config_file && -f $config_file) {
        %conf = ( read_config($config_file), %arg );
    }
    $database = $arg{'database'} if $arg{'database'};
    $database ||= $conf{'database'};
    set_env("$root/$database/ini/voyager.env");
    my $db       = $database || $conf{'default'};
    my $user     = $conf{$db}{'user'};
    my $password = $conf{$db}{'password'};
    my $dbid     = $conf{$db}{'sid'} || $ENV{'ORACLE_SID'} || $db;
    my %opt = ( %default_options, %{ $arg{'options'} || {} } );
    DBI->connect("dbi:Oracle:$dbid", $user, $password, \%opt);
}

sub read_config {
    my ($config_file) = @_;
    open my $fh, '<', $config_file or die "Can't open config file $config_file: $!";
    my (%conf, $db);
    local $/;
    local $_ = <$fh>;
    while (length) {
        next if s/\A\s*(?:#.*)?\n//;  # Strip blank lines and comments
        s/\A\s+//;
        if (s/\Adefault\s+\{//) {
            $db = '*';
        }
        elsif (s/\A\}//) {
            undef $db;
        }
        elsif (s/\Adatabase\s+(\S+)\s+\{\s+//) {
            $db = $1;
            $conf{$db} ||= {};
            # The first database defined is the default when connecting
            $database = $db if !defined $database;
        }
        elsif (s/\Adatabase\s+(\S+)\s+=\s+(\S+)//) {
            # Database alias
            $conf{$1} = $conf{$2} ||= {};
        }
        elsif (s/\A(option\s+)?(\S+)\s+(?:([1ty]|on)|([0fn]|off)|=\s+(.+))//i) {
            die "Not in default or database definition: $_" if !defined $db;
            my ($opt, $key, $on, $off, $val) = ($1, $2, $3, $4, $5);
            my $h = $conf{$db} ||= {};
            $h = $h->{'options'} ||= {} if defined $opt;
            $h->{$key} = defined $on ? 1 : defined $off ? 0 : $val;
        }
        else {
            die "Unrecognized stuff in config file $config_file: $_";
        }
    }
    foreach my $db (keys %conf) {
        next if $db eq '*';
        my $c = $conf{$db};
        while (my ($k, $v) = each %{ $conf{'*'} }) {
            if (ref $v) {
                ref($v) eq 'HASH' or die;
                $c->{$k} ||= {};
                while (my ($ik, $iv) = each %$v) {
                    $c->{$k}{$ik} = $iv if !exists $c->{$k}{$ik};
                }
            }
            else {
                $c->{$k} = $v if !exists $c->{$k};
            }
        }
    }
    close $fh;
    return %conf;
}

sub set_env {
    my ($f) = @_;
    open my $fh, '<', $f or die "Can't open voyager.env $f: $!";
    local $/ = "\n";
    while (<$fh>) {
        if (/^\s*export (ORA\w+)=(\S+)/) {
            $ENV{$1} = $2;
        }
    }
}

1;

=pod

=head1 NAME

Biblio::Vger::DBI - connect to a Voyager ILS database

=head1 SYNOPSIS

    # Auto-configure as much as possible
    use Biblio::Vger::DBI;

    # Specify database
    use Biblio::Vger::DBI 'xxxdb';

    # Rely on config file
    use Biblio::Vger::DBI
        config_file => '/path/to/some/file';

    # Actually connect using DBI
    my $dbh = Biblio::Vger->connect;
    my $dbh = Biblio::Vger->connect('xxxdb');
    my $dbh = Biblio::Vger->connect('database' => 'xxxdb');
    my $dbh = Biblio::Vger->connect(
        'database' => 'xxxdb',
        'user' => $user,
        'password' => $password,
        'options' => {
            'RaiseError' => 0,
        },
    );

=head1 DESCRIPTION

Biblio::Vger::DBI provides connectivity to a Vger database; it gives you one
place to put your Oracle environment variables, user name and password.

=cut

