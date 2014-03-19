package Biblio::Vger;

use Biblio::Vger::DBI;

use vars qw($VERSION);

$VERSION = '0.04';

sub new {
    my $cls = shift;
    bless { @_ }, $cls;
}

sub bib {
    my $self = shift;
    die if @_ != 1;
    my ($marc) = $self->marc('bib' => shift);
    return $marc;
}

sub mfhd {
    my $self = shift;
    die if @_ != 1;
    my ($marc) = $self->marc('mfhd' => shift);
    return $marc;
}

sub auth {
    my $self = shift;
    die if @_ != 1;
    my ($marc) = $self->marc('auth' => shift);
    return $marc;
}

sub dbh {
    my ($self) = @_;
    return $self->{'dbh'} ||= Biblio::Vger::DBI->connect || die;
}

sub marc {
    my ($self, $type, @ids) = @_;
    $type =~ /^(bib|mfhd|auth)/ or die;
    $type = $1;
    my @marc;
    my $dbh = $self->dbh;
    my $sth = $self->{"sth:marc:$type"} ||= $dbh->prepare("SELECT record_segment FROM ${type}_data WHERE ${type}_id = ? ORDER BY seqnum");
    foreach $id (@ids) {
        my $result = $sth->execute($id)
            || die sprintf "Unexpected error %s fetching %s record %s: %s", $sth->err, $type, $id, $sth->errstr;
        my ($segments) = $sth->fetchall_arrayref;
        $segments
            || die sprintf "No such %s record: %s", $type, $id;
        push @marc, join('', map { @$_ } @$segments);
    }
    return @marc;
}

1;

