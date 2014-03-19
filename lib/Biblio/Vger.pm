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
    Biblio::Vger::Bib->new(@_);
}

sub mfhd {
    my $self = shift;
    Biblio::Vger::Mfhd->new(@_);
}

sub auth {
    my $self = shift;
    Biblio::Vger::Auth->new(@_);
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

=pod

=head1 NAME

Biblio::Vger - Voyager ILS backend access

=head1 SYNOPSIS

    use Biblio::Vger;
    $bib = Biblio::Vger->bib($bib_id);
    $marc = $bib->marc;
    @mfhds = $bib->mfhds;
    $mfhd = Biblio::Vger->mfhd($mfhd_id);
    $bib = $mfhd->bib;

=cut
