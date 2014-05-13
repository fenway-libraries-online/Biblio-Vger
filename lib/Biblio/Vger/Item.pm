package Biblio::Vger::Item;

use strict;
use warnings;

use Biblio::Vger::Record;

use vars qw(@ISA);

@ISA = qw(Biblio::Vger::Record);

sub type { 'item' }

sub mfhd {
    my ($self) = @_;
    return $self->{'mfhd'} if $self->{'mfhd'};
    my $id = $self->id;
    my $sql = 'SELECT mfhd_id FROM mfhd_item WHERE item_id = ?';
    my $sth = $self->vger->query($sql)->execute($id);
    my ($mfhd_id) = $sth->fetchrow_array or die "Can't fetch: $sql";
    return $self->{'mfhd'} = Biblio::Vger::Mfhd->new($mfhd_id);
}

sub barcode {
    my ($self) = @_;
    return $self->{'barcode'} if exists $self->{'barcode'};
    my $id = $self->id;
    my $sql = 'SELECT item_barcode FROM item_barcode WHERE item_id = ? AND barcode_status = 1';  # 1 == active
    my $sth = $self->vger->query($sql)->execute($id);
    my ($barcode) = $sth->fetchrow_array or die "Can't fetch: $sql";
    return $self->{'barcode'} = $barcode;
}

sub fetch {
    my ($self) = @_;
    my $id = $self->id;
    my $sql = q{
SELECT  i.copy_number,
        to_char(i.create_date, 'YYYY-MM-DD'),
        to_char(i.modify_date, 'YYYY-MM-DD'),
        it.item_type_code,
        i.perm_location,
        i.temp_location,
        i.on_reserve,
        i.pieces,
        i.price
FROM    item i,
        item_type it
WHERE   i.item_type_id = it.item_type_id
AND     i.item_id = ?
};
    my $sth = $self->vger->query($sql)->execute($id);
    my ($copy_number, $create_date, $modify_date, $item_type, $perm_location, $temp_location, $on_reserve, $pieces, $price)
        = $sth->fetchrow_array;
    die if !defined $perm_location;
    %$self = (
        %$self,
        'copy_number'   => $copy_number,
        'create_date'   => $create_date,
        'modify_date'   => $modify_date,
        'item_type'     => $item_type,
        'perm_location' => $perm_location,
        'temp_location' => $temp_location,
        'on_reserve'    => ($on_reserve eq 'Y'),
        'pieces'        => $pieces,
        'price'         => $price,
    );
    return $self;
}

1;


