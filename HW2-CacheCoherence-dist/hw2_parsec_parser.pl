#!/usr/local/bin/perl

use Data::Dumper;

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 1) {
  print "\nUsage: hw2_parsec_parser.pl file_name\n";
  exit;
}

# (2) we got two command line args, so assume they are the
# first name and last name
$filename=$ARGV[0];

my @cols = ('CPUId', 'numReadHits', 'numReadMisses', 'numReadOnInvalidMisses', 'numReadRequestsSent', 'numReadMissesServicedByOthers', 'numReadMissesServicedByShared', 'numReadMissesServicedByModified', 'numWriteHits', 'numWriteMisses', 'numWriteOnSharedMisses', 'numWriteOnInvalidMisses', 'numInvalidatesSent');
my $numCols = $#cols + 1;

open (MYFILE, $filename);

my $inBenchmark = 0;
my $currBenchmark;

my @benchmarks;

my %benchmarkData;
my @protocols;

my $protocolCount;

while ($in = <MYFILE>) {
  if ($in =~ /\[========== Running benchmark (.*?) ==========\]/) {
    # Start of new benchmark
    $inBenchmark = 1;
    $currBenchmark = $1;
    %benchmarkData = (
      'name' => $currBenchmark,
      'protocols' => []
    );
    @protocols = ();
    $protocolCount = -1;
    #print $currBenchmark . "\n";
    print $currBenchmark . "\n";
  } elsif ($inBenchmark) {
    if ($in =~ /\[----------    End of output    ----------\]/) {
      # End of current benchmark
      $inBenchmark = 0;
      $numProtocols = $#protocols + 1;
      #print "  length: $len\n";
      # Print out data for each protocol
      #for ($i = 0; $i < $numProtocols; $i++) {
      foreach (@protocols) {
        #%protocol = %{$protocols[$i]};
        $ref = $_;
        %protocol = %{$_};
        #print "  $protocol{'name'}\n";
        print '  ' . $protocol{'name'} . "\n";
        @data = @{$protocol{'data'}};

        # Total up the counter values
        my @totals = (0) x $numCols;
        foreach (@data) {
          @row = @{$_};
          print '    Thread ' . $row[0] . ":\n";
          for ($i = 1; $i < $#row; $i++) {
            print "      $cols[$i]: $row[$i]\n";
            $totals[$i] += $row[$i];
          }
        }
        $ref->{'totals'} = \@totals;

        print "    Total:\n";
        for ($i = 1; $i < $#totals; $i++) {
          print "      $cols[$i]: $totals[$i]\n";
        }
      }
      # Add info to global data
      my @newProtocols = @protocols;
      $benchmarkData{'protocols'} = \@newProtocols;
      my %newBenchData = %benchmarkData;
      push @benchmarks, \%newBenchData;
    } elsif ($in =~ /Loaded Protocol Plugin .*\/(.*\.so)/) {
      # Add protocol
      my %dat = ('name' => $1, 'data' => []);
      push @protocols, \%dat;
    } elsif ($in =~ /^(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)/) {
      # Row of counter data
      $id = $1;
      if ($id == 0) {
        # Beginning of new set of data (one set for each protocol, one row per thread)
        $protocolCount++;
      }
      my @vals = split(/,/, $in);
      push @{$protocols[$protocolCount]->{'data'}}, \@vals;
    }
  }
}

#print Dumper(\@benchmarks);

close(MYFILE);