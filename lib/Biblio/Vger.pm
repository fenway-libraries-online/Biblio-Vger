package Biblio::Vger;

use Biblio::Vger::DBI;
use Biblio::Vger::Query;
use Biblio::Vger::Bib;
use Biblio::Vger::Mfhd;
use Biblio::Vger::Auth;

use vars qw($VERSION);

$VERSION = '0.05';

sub new {
    my $cls = shift;
    bless { @_ }, $cls;
}

sub query {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Query->new(@_, 'vger' => $self);
}

sub bib {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Bib->new(@_, 'vger' => $self);
}

sub mfhd {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Mfhd->new(@_, 'vger' => $self);
}

sub auth {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Auth->new(@_, 'vger' => $self);
}

sub dbh {
    my $self = shift;
    $self = $self->new if !ref $self;
    return $self->{'dbh'} ||= Biblio::Vger::DBI->connect(@_) || die;
}

sub marc {
    my ($self, $type, @ids) = @_;
    $type =~ /^(bib|mfhd|auth)/i or die;
    $type = lc $1;
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
