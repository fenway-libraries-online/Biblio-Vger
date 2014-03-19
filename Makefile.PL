use ExtUtils::MakeMaker;

WriteMakefile(
  'PL_FILES' => {},
  'NAME' => 'Biblio::Vger',
  'EXE_FILES' => [],
  'VERSION_FROM' => 'lib/Biblio/Vger.pm',
  'PREREQ_PM' => {
                   'Test::More' => 0,
                   'Getopt::Long' => 0,
                   'DBD::Oracle' => 0,
                   'DBI' => 0,
                 }
)
;
