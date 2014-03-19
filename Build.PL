use Module::Build;

my $b = Module::Build->new(
    'module_name'        => 'Biblio::Vger',
    'abstract'           => 'Voyager ILS backend access',
    'script_files'       => [ ],
    'license'            => 'perl',
    'requires'           => {
        'Getopt::Long'       => 0,
        'DBD::Oracle'        => 0,
        'DBI'                => 0,
    },
    'build_requires'     => {
        'Test::More'         => 0,
    },
    'create_makefile_pl' => 'traditional',
    'create_readme'      => 0,
    'sign'               => 0,
);

$b->create_build_script;

