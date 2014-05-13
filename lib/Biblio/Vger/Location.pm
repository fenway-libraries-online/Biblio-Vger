package Biblio::Vger::Location;

use Biblio::Vger;

sub id { @_ > 1 ? $_[0]->{'id'} = $_[1] : $_[0]->{'id'} }
sub code { @_ > 1 ? $_[0]->{'code'} = $_[1] : $_[0]->{'code'} }
sub vger { @_ > 1 ? $_[0]->{'vger'} = $_[1] : $_[0]->{'vger'} }

sub new {
    my $cls = shift;
    unshift @_, 'id' if @_ % 2;
    bless { @_ }, $cls;
}

sub fetch {
    my ($self) = @_;
    my ($id, $code) = @$self{qw(id code)};
    $id ||= $self->fetch->id;
    my $sql = 'SELECT * FROM location WHERE location_code = ?';
    my $query = $vger->query($sql);
    my $sth = $query->execute($code);
    my $h = $sth->fetchrow_hashref or die;
    %$self = ( %$self, %$h );
    return $self;
}

sub bib_iter {
    my ($self) = @_;
    my $vger = $self->vger;
    my $id = $self->id || $self->fetch->id;
    my $sql = q{
        SELECT  bm.bib_id
        FROM    bib_mfhd    bm,
                mfhd_master mm,
                location    l
        WHERE   bm.mfhd_id = mm.mfhd_id
        AND     mm.location_id = l.location_id
        AND     l.location_id = ?
        ORDER BY bm.bib_id
    };
    my $query = $vger->query($sql);
    my $sth = $query->execute($id);
    return sub {
        if (my ($bib_id) = $sth->fetchrow_array) {
            return $vger->bib($bib_id);
        }
        return;
    }
}

sub bibmfhd_iter {
    my ($self) = @_;
    my $vger = $self->vger;
    my $id = $self->id || $self->fetch->id;
    my $sql = q{
        SELECT  bm.bib_id,
                bm.mfhd_id
        FROM    bib_mfhd    bm,
                mfhd_master mm,
                location    l
        WHERE   bm.mfhd_id = mm.mfhd_id
        AND     mm.location_id = l.location_id
        AND     l.location_id = ?
        ORDER BY bm.bib_id, bm.mfhd_id
    };
    my $query = $vger->query($sql);
    my $sth = $query->execute($id);
    my $prev_bib_id = 0;
    my $bib;
    return sub {
        if (my ($bib_id, $mfhd_id) = $sth->fetchrow_array) {
            $bib = $vger->bib($bib_id) if $bib_id != $prev_bib_id;
            $prev_bib_id = $bib_id;
            return ( $bib, $vger->mfhd($mfhd_id) );
        }
        return;
    }
}

sub mfhd_iter {
    my ($self) = @_;
    my $vger = $self->vger;
    my $id = $self->id || $self->fetch->id;
    my $sql = 'SELECT mfhd_id FROM mfhd_master WHERE location_id = ? ORDER BY mfhd_id';
    my $query = $vger->query($sql);
    my $sth = $query->execute($id);
    return sub {
        if (my ($mfhd_id) = $sth->fetchrow_array) {
            return $vger->mfhd($mfhd_id);
        }
        return;
    }
}

1;
