package Biblio::Vger;

use Biblio::Vger::DBI;
use Biblio::Vger::Query;
use Biblio::Vger::Bib;
use Biblio::Vger::Mfhd;
use Biblio::Vger::Item;
use Biblio::Vger::Auth;
use Biblio::Vger::Location;

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

sub item {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Item->new(@_, 'vger' => $self);
}

sub auth {
    my $self = shift;
    $self = $self->new if !ref $self;
    Biblio::Vger::Auth->new(@_, 'vger' => $self);
}

sub dbh {
    my $self = shift;
    $self = $self->new if !ref $self;
    my %opt = ( @_, 'options' => {'FetchHashKeyName' => 'NAME_lc'} );
    return $self->{'dbh'} ||= Biblio::Vger::DBI->connect(%opt) || die;
}

sub marc {
    my ($self, $type, @ids) = @_;
    $type =~ /^(bib|mfhd|auth)/i or die;
    $type = lc $1;
    my @marc;
    my $query = $self->{"query:marc:$type"} ||= $self->query("SELECT record_segment FROM ${type}_data WHERE ${type}_id = ? ORDER BY seqnum");
    foreach $id (@ids) {
        my $sth = $query->execute($id);
        my ($segments) = $sth->fetchall_arrayref;
        $segments || die sprintf "No such %s record: %s", $type, $id;
        push @marc, join('', map { @$_ } @$segments);
    }
    return @marc if wantarray;
    return if !@marc;
    die "Multiple MARC records retrieved" if @marc > 1;
    return $marc[0];
}

sub bib_iter {
    my ($self, $begin, $end) = @_;
    $self = $self->new if !ref $self;
    my $query = $self->query('SELECT bib_id FROM bib_master WHERE bib_id BETWEEN ? AND ?');
    my $sth = $query->execute($begin, $end);
    return sub {
        if (my ($bib_id) = $sth->fetchrow_array) {
            return $self->bib($bib_id);
        }
        return;
    }
}

sub locations {
    my ($self) = @_;
    my $query = $self->query('SELECT location_id AS id FROM location');
    my $sth = $query->execute;
    return map { Biblio::Vger::Location->new(%$_, 'vger' => $self) } @{ $sth->fetchall_arrayref({}) };
}

1;

=pod

=head1 NAME

Biblio::Vger - Voyager ILS backend access

=head1 SYNOPSIS

    use Biblio::Vger;

    $dbh   = Biblio::Vger->dbh(%options);

    $bib   = Biblio::Vger->bib($bib_id);
    $marc  = $bib->marc;
    @mfhds = $bib->mfhds;

    $mfhd  = Biblio::Vger->mfhd($mfhd_id);
    $bib   = $mfhd->bib;

=head1 DESCRIPTION

Biblio::Vger provides convenient object-oriented access to the data in a
Voyager ILS database.

=head1 AUTHOR

Paul Hoffman <paul@flo.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2014 by Fenway Libraries Online.

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

Biblio::Vger::DBI, Biblio::Vger::Query, Biblio::Vger::Bib, Biblio::Vger::Mfhd,
Biblio::Vger::Item, Biblio::Vger::Auth, Biblio::Vger::Location

=cut
