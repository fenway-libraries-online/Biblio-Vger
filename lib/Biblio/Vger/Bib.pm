package Biblio::Vger::Bib;

use base qw(Biblio::Vger::Record);

sub type { 'bib' }

sub mfhds {
    my ($self) = @_;
    return @{ $self->{'mfhds'} } if $self->{'mfhds'};
    my @mfhds;
    my $id    = $self->id;
    my $sql   = 'SELECT mfhd_id FROM bib_mfhd WHERE bib_id = ?';
    my $vger  = $self->{'vger'} ||= Biblio::Vger->new;
    my $query = $vger->query($sql);
    my $sth   = $query->execute($id);
    while (my ($mfhd_id) = $sth->fetchrow_array) {
        push @mfhds, $vger->mfhd($mfhd_id);
    }
    $self->{'mfhds'} = \@mfhds;
    return @mfhds;
}

1;

