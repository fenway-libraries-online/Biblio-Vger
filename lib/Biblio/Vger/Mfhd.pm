package Biblio::Vger::Mfhd;

use base qw(Biblio::Vger::Record);

sub type { 'mfhd' }

sub bib {
    my ($self) = @_;
    return $self->{'bib'} if $self->{'bib'};
    my $id = $self->id;
    my $sql = 'SELECT bib_id FROM bib_mfhd WHERE mfhd_id = ?';
    my $sth = Biblio::Vger->query($sql);
    my ($bib_id) = $sth->fetchrow_array or die "Can't fetch: $sql";
    return $self->{'bib'} = Biblio::Vger::Bib->new($bib_id);
}

sub items {
    my ($self) = @_;
    return @{ $self->{'items'} } if $self->{'items'};
    my @items;
    my $id    = $self->id;
    my $sql   = 'SELECT item_id FROM mfhd_item WHERE mfhd_id = ?';
    my $vger  = $self->{'vger'} ||= Biblio::Vger->new;
    my $query = $vger->query($sql);
    my $sth   = $query->execute($id);
    while (my ($item_id) = $sth->fetchrow_array) {
        push @items, $vger->item($item_id);
    }
    $self->{'items'} = \@items;
    return @items;
}

1;

