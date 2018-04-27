#!/usr/bin/perl

use Math::BigInt;
use Math::Complex;

## Prime factors crack, written by Sean Greathouse
## This will take a large integer, and hunt for all prime factors up to 
## $limit, and then divide the large integer by these prime factors.
## I then look for unusual occurances of numbers within the divided 
## answers.  If a number occurs more than 15% of the total length, I 
## consider it a potential hit, which could represent a cipher, to be cracked.
## ALL CODE IS MINE, Do not use without permission. 
## Email: sean.greathouse@gmail.com

print "Enter your number: ";
$x = <>;
chomp($x);

$limit = 1000000;

$x = Math::BigInt->new($x);
$big_number = $x;
#print "X is $x\n";
$i=0;

print "Finding prime factors.. this can take a LONG time if \$limit is set very high!\n";
#for ( my $y = 2; $y <= $x; $y++ ) { ## To find ALL factors, may take a long time
for (my $y = 2; $y <= $limit; $y++) {
    #print "Trying $y\n";
    if($x % $y!=0) {
	next;
    }
    #next if $x % $y;
    $x /= $y;
    $factors[$i] = $y;
    $i++;
    #print $y, "\n";
    redo;
}
@factors = reverse(@factors);
print "Factors are: @factors\n";
print "Beginning crack...\n";
$crack_me = $big_number;
$arrSize = scalar(@factors) - 1;
for($i=0; $i<=$arrSize; $i++) {
	$notice = 0; ## Don't notice anything at first.
	print "Trying $factors[$i]\n";
	$crack_me = $crack_me / $factors[$i];
	#print "$crack_me\n";
	#print "Let's look for patterns, notice any?\n";
	@allnums = split("", $crack_me);
	$total_size = scalar(@allnums) - 1;
	#print "Your hash is $total_size characters\n";
	## Create a count hash for each number in the array
	## and count how many times each number occurs.  
	my %count;
	$count{$_}++ foreach @allnums;
	while (my ($key, $value) = each(%count)) {
		## Here we remove any keys that exist
		## only once. 
		if($value == 1) {
			delete($count{$key});
		}
	}
	while (my ($key, $value) = each(%count)) {
		## Here we want to see if a value is 10% or more
		## of the total length of numbers of the code.
		## This would indicate heavy bias of certain numbers
		## which could indicate a potential cipher!
		$percent = ($value / $total_size) * 100;
		if($percent >= 15) {
			$notice = 1;
			print "The number $key occurs $value times! \($percent\%\!\)\n";
		}
		print "$key : $value\n";
	}
	if($notice == 1) {
		print "POTENTIAL CIPHER FOUND!\n";
		print "Code: $crack_me\n";
		$j=0;
        	foreach $num (@allnums) {
                	print $num . "  ";
                	$j++;
                	if($j % 10==0) {
                        	print "\n";
                	}
        	}
	}
	print "\n===================================\n";
}

