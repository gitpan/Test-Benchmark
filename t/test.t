use strict;
use warnings;

use Test::More tests => 15;
use Test::NoWarnings;

use Test::Benchmark;

use Test::Tester;

Test::Benchmark::builder(Test::Tester::capture());


my $fac30 = sub {fac(30)};
my $fac20 = sub {fac(20)};
my $fac10 = sub {fac(10)};

check_test(
	sub {
		is_faster(-1, $fac10, $fac20, "10 faster than 20");
	},
	{
		actual_ok => 1,
		diag => "",
		name => "10 faster than 20",
	},
	"10 faster than 20"
);

check_test(
	sub {
		is_faster(-1, $fac20, $fac10, "20 faster than 10");
	},
	{
		actual_ok => 0,
	},
	"20 slower than 10"
);

check_test(
	sub {
		is_faster(-1, 2, $fac10, $fac30, "30 2 times faster than 10");
	},
	{
		actual_ok => 0,
	},
	"30 2 times than 10"
);

sub fac
{
	my $x = shift;
	return 1 if $x <= 1;
	return $x * fac($x-1);
}
