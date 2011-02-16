use strict;
use warnings;

use Test::More 0.88;
use File::Temp qw/ tempdir /;
use PAUSE::mldistwatch;

my ($mlroot, $self);

no warnings 'redefine';
*PAUSE::newfile_hook = sub ($) {};
*PAUSE::dist::mlroot = sub { $mlroot };
*PAUSE::dist::verbose = sub {};
use warnings;

sub setup_test {
    my ($manifound) = @_;
    $mlroot = tempdir(CLEANUP => 1);
    $self = bless {
        SUFFIX => 'tgz',
        DIST => 'Acme-Foo-0.001.tgz',
        MANIFOUND => $manifound,
        mlroot => $mlroot,
    }, 'PAUSE::dist';
}

setup_test([]);
ok !$self->extract_json;
is $self->{JSON}, "No META.json found";

setup_test([]);
$self->extract_json_or_yaml;
is $self->{JSON}, "No META.json found";
is $self->{YAML}, "No META.yml found";

setup_test(['/META.json']);
$self->extract_json_or_yaml;
is $self->{JSON}, "Empty META.json found, ignoring";
is $self->{YAML}, "No META.yml found";
is $self->{YAML_CONTENT}, undef;

setup_test(['/META.yml']);
$self->extract_json_or_yaml;
is $self->{JSON}, "No META.json found";
is $self->{YAML}, "Empty META.yml found, ignoring";
is_deeply $self->{YAML_CONTENT}, undef;

setup_test(['/META.yml', '/META.json']);
$self->extract_json_or_yaml;
is $self->{JSON}, "Empty META.json found, ignoring";
is $self->{YAML}, "Empty META.yml found, ignoring";
is_deeply $self->{YAML_CONTENT}, undef;

done_testing;
