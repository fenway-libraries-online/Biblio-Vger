package Biblio::Vger::Record;

use Biblio::Vger;

sub type { die "Abstract base class" }

sub id { @_ > 1 ? $_[0]->{'id'} = $_[1] : $_[0]->{'id'} }
sub vger { @_ > 1 ? $_[0]->{'vger'} = $_[1] : $_[0]->{'vger'} }

sub new {
    my $cls = shift;
    die "Abstract base class" if $cls eq __PACKAGE__;
    unshift @_, 'id' if @_ % 2;
    bless { @_ }, $cls;
}

sub marc {
    my ($self) = @_;
    return $self->{'marc'} if exists $self->{'marc'};
    ($self->{'marc'}) = $self->vger->marc($self->type => $self->id);
    return $self->{'marc'};
}

1;

=pod

=head1 NAME

Biblio::Vger::Record - a bib, holding, or authority record in the Voyager ILS

=head1 DESCRIPTION

This is an abstract base class with a subclass for each different type of
MARC record in a Voyager ILS database.

=head1 METHODS

=over 4

=item B<new>

    $rec = Biblio::Vger::Bib->new($id);
    $rec = Biblio::Vger::Mfhd->new($id);
    $rec = Biblio::Vger::Auth->new($id);
    
    $rec = Biblio::Vger::Bib->new(id => $id);
    $rec = Biblio::Vger::Mfhd->new(id => $id);
    $rec = Biblio::Vger::Auth->new(id => $id);

=item B<id>

    $id = $rec->id;
    $rec->id($id);

Get or set the record ID.

=item B<marc>

    $marc = $rec->marc;

Get the MARC record itself.  The string returned is a raw MARC record, i.e., the first 24 bytes are the leader, then the directory follows, etc., etc.

To turn this into a useable Perl data structure you will probably want to use
a suitable class such as L<MARC::Record|MARC::Record>.

=back

=cut

