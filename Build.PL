
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Request" => 0,
    "HTTP::Request::Common" => 0,
    "Module::Build" => "0.3601",
    "Plack::Builder" => 0,
    "Plack::Test" => 0,
    "Test::More" => "0.88"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "PJAX for your Plack",
  "dist_author" => [
    "Matthew Phillips <mattp\@cpan.org>"
  ],
  "dist_name" => "Plack-Middleware-Pjax",
  "dist_version" => "1.113400",
  "license" => "perl",
  "module_name" => "Plack::Middleware::Pjax",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Marpa::HTML" => 0,
    "Plack::Middleware" => 0,
    "Plack::Request" => 0,
    "Plack::Util" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
