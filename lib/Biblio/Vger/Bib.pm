package Biblio::Vger::Bib;

use base qw(Biblio::Vger::Record);

sub type { 'bib' }

sub mfhds {
    my ($self) = @_;
    my $id = $self->id;
    xxx;
}

1;

