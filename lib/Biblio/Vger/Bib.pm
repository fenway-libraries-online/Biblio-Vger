package Biblio::Vger::Bib;

use base qw(Biblio::Vger::Record);

sub type { 'bib' }

sub mfhd_iter {
    my ($self) = @_;
    my @mfhds = $self->mfhds;
    return sub {
        return if !@mfhds;
        shift @mfhds;
    }
}

sub mfhds {
    my ($self) = @_;
    return @{ $self->{'mfhds'} } if $self->{'mfhds'};
    my @mfhds;
    my $vger  = $self->{'vger'} ||= Biblio::Vger->new;
    my $sql   = 'SELECT mfhd_id FROM bib_mfhd WHERE bib_id = ?';
    my $id    = $self->id;
    my $sth   = $vger->query($sql)->execute($id);
    while (my ($mfhd_id) = $sth->fetchrow_array) {
        push @mfhds, $vger->mfhd($mfhd_id);
    }
    $self->{'mfhds'} = \@mfhds;
    return @mfhds;
}

1;

