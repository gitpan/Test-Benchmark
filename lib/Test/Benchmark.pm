# Copyright 2003 Fergal Daly <fergal@esatclear.ie> distributed under the GNU
# Lesser General Public License, you do not have to accept this license but
# nothing else gives you the right to use this software

use strict;
use warnings;

package Test::Benchmark;

use Test::Builder;

use Benchmark qw( timethis timestr );

use vars qw(
	$VERSION @EXPORT @ISA @CARP_NOT
);

$VERSION = "0.001";

my $Test = Test::Builder->new;

require Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( is_faster is_n_times_faster );

use Carp qw( croak );
@CARP_NOT = qw( Test::Benchmark Benchmark );

sub is_faster
{
	if (ref $_[1])
	{
		is_n_times_faster(1, @_);
	}
	else
	{
		is_n_times_faster(@_);
	}
}

sub is_n_times_faster
{
	my $factor = shift;
	my $times = shift;
	my $code1 = shift;
	my $code2 = shift;
	my $name = shift;

	my @res;

	my ($res1, $res2) = map {get_res($times, $_)} ($code1, $code2);

	my($r1, $pu1, $ps1, $cu1, $cs1, $n1) = @$res1;
	my($r2, $pu2, $ps2, $cu2, $cs2, $n2) = @$res2;

	# we want code1 to be faster than code2. Essentially we are comparing 2
	# fractions factor * n1/cpu1 > n2/cpu2 but in order to avoid div by zero
	# we use multiplication

	if ($n1 * ($pu2 + $pu1) * $factor > $n2 * ($pu1 + $pu2))
	{
		$Test->ok(1, $name);
	}
	else
	{
		$Test->ok(0, $name);
		my $extra = ($factor == 1) ? "" : " at least $factor times";
		$Test->diag("code1 was not$extra faster than code 2");
		$Test->diag(timestr($res1));
		$Test->diag(timestr($res2));
	}
#	use Data::Dumper qw(Dumper);
#	print Dumper($res1, $res2);
}

sub get_res
{
	my ($times, $sub) = @_;

	if (ref($sub) eq "Benchmark")
	{
		return $sub;
	}
	elsif (0)
	{
		# get from cache not implemented - maybe never will be...
	}
	else
	{
		croak "You must provide a number of iterations" unless defined($times);
		return timethis($times, $_, "", "none");
	}
}

sub builder
{
	if (@_)
	{
		$Test = shift;
	}
	return $Test;
}

1;

__END__

=head1 NAME

Test::Benchmark - Make sure something really is faster

=head1 SYNOPSIS

  use Test::More test => 17;
  use Test::Benchmark;

  is_faster(-10, sub {...}, sub {...}, "this is faster than that")
  is_faster(5, -10, sub {...}, sub {...}, "this is 5 times faster than that")
  is_n_times_faster(5, -10, sub {...}, sub {...}, "this is 5 times faster than that")

	is_faster(-10, $bench1, $bench2, "res1 was faster than res2");

=head1 DESCRIPTION

Sometimes you want to make sure that your "faster" algorithm really is
faster than the old way. This lets you check. It might also be useful to
check that your super whizzo XS or Inline::C version is actually faster.

This module is based on the standard L<Benchmark> module. If you have lots
of timings to compare and you don't want to keep running the same benchmarks
all the time, you can pass in a result object from C<Benchmark::timethis()>
instead of sub routine reference.

=head1 USAGE

There are 2 functions exported: C<is_faster()> and C<is_n_times_faster()>.
Actually C<is_n_times_faster()> is redundant because C<is_faster()> can do
the same thing just by giving it an extra argument.

Anywhere you can pass a subroutine reference you can also pass in a
L<Benchmark> object.

	# call as
	# is_faster($times, $sub1, $sub2, $name)
	# is_faster($faster, $times, $sub1, $sub2, $name)

=head2 is_faster()

is_faster($times, $sub1, $sub2, $name)

is_faster($factor, $times, $sub1, $sub2, $name)

This runs each subroutine reference C<$times> times and then compares the
results. Instead of either subroutine reference you can pass in a
L<Benchmark> object. If you pass in 2 L<Benchmark> objects then C<$times> is
irrelevant.

If C<$times> is negative then that speicifies a minimum duration for the
benchmark rather than a number of iterations (see L<Benchmark> for more
details). B<I strongly recommend you use this feature if you want your
modules to still pass tests reliably on machines that are much faster than
your own.> 10000 iterations may be enough for a reliable benchmark on your
home PC but it be just a twinkling in the eye of somebody else's super
computer.

If the test fails, you will get a diagnostic output showing the benchmark
results in the standard L<Benchmark> format.

=head2 is_n_times_faster()

is_n_times_faster($factor, $times, $sub1, $sub2, $name)

This is exactly the same as the second form of is_faster but it's just
explicit about the "n times" part.

=head1 DANGERS

Benchmarking can be slow so please consider leaving out benchmark tests from
your default test suite, perhaps only running them if the user has set a
particualr environment variable.

Some benchmarks are inherently unreliable.

=head1 BUGS

None that I know of.

=head1 DEPENDENCIES

L<Benchmark>, L<Test::Builder> but they come with most Perl's.

=head1 HISTORY

This came up on the perl-qa mailing list, no one else.

=head1 SEE ALSO

L<Test::Builder>, L<Benchmark>

=head1 AUTHOR

Written by Fergal Daly <fergal@esatclear.ie>.

=head1 COPYRIGHT

Copyright 2003 by Fergal Daly E<lt>fergal@esatclear.ieE<gt>.

This program is free software and comes with no warranty. It is distributed
under the LGPL license. You do not have to accept this license but nothing
else gives you the right to use this software.

See the file F<LGPL> included in this distribution or
F<http://www.fsf.org/licenses/licenses.html>.

=cut
