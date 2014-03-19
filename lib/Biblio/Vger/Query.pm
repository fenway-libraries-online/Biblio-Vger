package Biblio::Vger::Query;

sub vger { @_ > 1 ? $_[0]->{'vger'} = $_[1] : $_[0]->{'vger'} }
sub sql { @_ > 1 ? $_[0]->{'sql'} = $_[1] : $_[0]->{'sql'} }
sub dbh { @_ > 1 ? $_[0]->{'dbh'} = $_[1] : $_[0]->{'dbh'} }
sub sth { @_ > 1 ? $_[0]->{'sth'} = $_[1] : $_[0]->{'sth'} }

sub new {
    my $cls = shift;
    unshift @_, 'sql' if @_ % 2;
    my $self = bless { @_ }, $cls;
    my $vger = $self->vger;
    my $sql  = $self->sql;
    my $dbh  = $self->{'dbh'} = $vger->dbh;
    $self->{'sth'} = $dbh->prepare($sql) or die "Can't prepare: $sql";
    return $self;
}

sub execute {
    my $self = shift;
    my $sth = $self->sth;
    my $dbh = $self->dbh;
    $sth->execute(@_) or die $dbh->errstr;
    return $sth;
}

1;
