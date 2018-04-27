#!/usr/bin/perl

## Homemade RSA encrpytion.  Let's do this!
## Built from the method listed here: https://simple.wikipedia.org/wiki/RSA_(algorithm)
## By: Sean Greathouse

use strict;
use Math::BigInt;
use Math::BigInt::Random qw/random_bigint/;

## First, we want to find two very large prime numbers.  We need to use the Miller-Rabin primality test
## if we want to do this in any sort of decent time frame.  

my $large_start = Math::BigInt->new("230998374598236756724562824562345626828214356233745986878911");
my $large_end = Math::BigInt->new(my $large_end);

## Here, I strip the last number in $large_start, and check if it's 1, 3, 7 or 9.  Primes Aside from 2 and 5, all primes end in those numbers.
#print "Large start is $large_start\n";
my $last_string = substr $large_start, -1;
if(($last_string == 0) || ($last_string == 2) || ($last_string == 4) || ($last_string == 5) || ($last_string == 6) || ($last_string == 8)) {
    print "Number cannot be prime.  Adding 1 to lessen the workload.\n";
    $large_start++;
}
    
print "Starting number is $large_start\n";
sleep 5;
$large_end = $large_start + 1;
my @prime_array;

my $j=0;
my $i=0;
while(!($prime_array[1])) { ## We want to test in 2 number increments (to stay odd) until we find two large prime numbers. 
    
    #while($i < $large_end) {
    #    $i=$large_start;
    for(my $i=$large_start; $i<$large_end; $i++) {
        #sleep 1;
        my $last_string = substr $i, -1;
        if(($last_string == 0) || ($last_string == 2) || ($last_string == 4) || ($last_string == 5) || ($last_string == 6) || ($last_string == 8)) {
            #print "Number cannot be prime.  Adding 1 to lessen the workload.\n";
            $i++;
        }
        print "Checking $i for primality\n";
        my $prime_check = miller_rabin($i);
        if($prime_check == 1) {
            print "$i is prime\n";
            $prime_array[$j] = $i;
            $j++;
            if(!$prime_array[1]) {
                print "We need a second prime. Keep hunting!\n";
                
            }
        }
        else {
            #print "$i is not prime\n";
            
        }
    }
    #sleep 5;
    $large_start = $large_end + 1;
    $large_end += 2;
} 

## At this point, we have two very large prime numbers. 
print "So we have found two very large prime numbers!  This is exactly what you want for encryption";
print " purposes!\nWe call them P and Q.\n";
my $p = $prime_array[0];
my $q = $prime_array[1];
print "P is $p\n";
print "Q is $q\n";

## Multiply them together to make a really big n
print "Now we want to multiply those two primes together, to make a really big N value.\n";
my $n = $p * $q;
print "Big N is $n\n";

## Next, multiply (p-1)(q-1), call it phi.  This is the totient.
## Note: In version PKCS#1 V2.0, they suggest finding the least common multiple of (p-1,q-1), but
## at this point I'm too lazy to go through the effort.   
print "Now we multiply (p-1)(q-1), and call it phi. This is our totient.\n";
my $phi = ($p - 1) * ($q - 1);
print "Big Phi is $phi\n";

## Next, find the greatest common divisor using the Euclidean algorithm
## Loop through $e until you find a value that $gcd = 1;
print "Now we want to find the greatest common divisor using the Euclidean algorithm.\nThis was created";
print " thousands of years ago!\n";
print "First, we want to find a random coprime number, that is at least 4 digits long.\n4 digits is to make sure";
print " your exponent is large enough so that your cipher can handle your mod.\n";
my ($i, $gcd, $e, $f, $g);
$i=int(rand(1000)) + 1000; ## We want a coprime that is at least 4 digits long, for security reasons. 
while($gcd != 1) {
    $e = $i;
    print "Trying $e...\n";
    ($gcd, $f, $g) = euclidean($e, $phi);
    print "E is $e, and GCD is $gcd\n";
    $i++;
}
my $a = $f / $gcd;
my $b = $g / $gcd;
my $d = $phi + $f;


print "My GCD is $gcd\n";
print "My multiplicative inverse of $e mod ($phi)\nis\n$d\n\n";
print "Soooooo.....\n\n";
print "Your public key is n = $n and e = $e\n";
print "Your private key is n = $n and d = $d\n";
print "--------------------------------------------------------\n";
print "To encrypt a message, obtain their public key.  This will be their n and e values.\n";
print "Encipher your message into a number. Call it m.\n";
print "Compute m^e(mod n).  This will be M.  Send M to the other person\n";
print "--------------------------------------------------------\n";
print "To decrypt a message, let M be the message you receive.  Use your private key of n and d.\n";
print "Compute M^d(mod n). Call this m.  Convert m back to the original message. (decipher it)\n";

print "\nLet's try it!  First, we need a message.  Type something in to encipher it!\n>";
my $message = <>;
chomp($message);
print "Your message is: $message\n";
print "\nGreat.  Now, we need to encipher the message.\n";
print "I simply use perls ord() function to translate each character into it's Perl\nnumbered equivalent.\n";
print "Then I append each character together with a 128, which is a weird version of\nthe letter C.\n";
print "This is used as a delimiter, so we can recreate the message on the other side, so to speak.\n";
print "This is a weakness in the cipher, but that's why we have encryption!  Ciphers are typically\n";
print "much weaker than encrypted messages.  If you're interested more in ciphers, check out the Vinegere cipher!\n\n";
print "Anyways, once we have created our cipher, we call this m.  (See above!)\n";
my @chars = split("", $message);
my $cipher;

$i = 0; ## Used to increment the @numbers array, which I will use to
        ## capture all the number values of the characters.  I'll use it
        ## later.
foreach my $char (@chars) {
        print "Translating: $char\n";
        my $num = ord($char);
	if($num == 128) {
		$num = 67; ## Swap crazy C with capital C, and use for delim
	}
	#print "$char is now $num\n";
	$cipher = "$cipher" . "$num" . "128";
        print "$cipher\n";
}
my $m = Math::BigInt->new($cipher); ## Used to hold the cipher.
print "Cipher is: $cipher\n\n";

print "So now, let's pretend the n and e values we calculated before, are someone else's public key, instead of ours.\n";
print "To encrypt our message, we want to compute m^e (mod n).  We will call this M.  This is our encrypted final message!\n";
print "Let's recall our numbers.\n";
print "Our cipher message m is: $cipher\n";
print "Our e value is: $e\n";
print "Our n value is: $n\n";
print "Formula will be $m ^ $e (mod $n)\n";
my $M = $m->bmodpow($e, $n);
        
print "Thus, our final encrypted message is:\n";
print "$M\n";

print "So now to decrypt the message, we want to take our private keys of n and d, and compute\nM^d (mod n).\n";
print "Call this decipher.  Convert decipher back to the original message. (Decipher it)\n";
print "Our formula will be $M ^ $d (mod $n)\n";
my $decipher = $M->bmodpow($d, $n);
print "Decipher is $decipher\n";
print "So let's translate the cipher back into original text.\n";

## Decipher method, first decrypt. 

#my $message = $
my @numerical_chars = split("128", $decipher);
foreach my $num (@numerical_chars) {
	print "$num\n";
	my $char = chr($num);
	print "Num $num is now $char\n";
	#print "$char";
}
print "\n";


sub miller_rabin {## https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    my $n = shift;
    my $d = $n - 1;
    #print "N is $n\n";
    #print "D is $d\n";
    my $s = 0;
    while ($d % 2 == 0) {
        #print "D is $d\n";
        $d /= 2;
        #print "D is $d\n";
        $s++;
    }
    #print "D is $d\n";
LOOP: for (my $i = 0; $i < 20; $i++) {
        my $a = random_bigint(min => 2, max => $n - 2); ## Random_bigint and bmodpow are part of BigInt and BigInt::Random
        #my $a = 2 + int(rand($n-2));
        #print "Random bigint is $a\n";
        #print "ADN = $a, $d, $n\n";
        my $x = $a->bmodpow($d, $n);
        next LOOP if $x == 1 || $x == $n - 1;
        for (my $r = 1; $r < $s; $r++) {
            $x = $x->bmodpow(2, $n);
            return 0 if $x == 1;  # definitely composite
            next LOOP if $x == $n - 1;
        }
        return 0;  # definitely composite
    }
    return 1;  # probably prime
}

sub euclidean { ## Creating the extended Eucilidean algorithm.  
                ## Example of method here: http://www.math.cmu.edu/~bkell/21110-2010s/extended-euclidean.html
    my $a = shift;
    #print "My A is $a\n";
    my $b = shift;
    #print "My B is $b\n";
    my ($c, $ca, $cb, $d, $da, $db);
    if ($a >= $b) {
        $c = $a;  $ca = 1;  $cb = 0;
        $d = $b;  $da = 0;  $db = 1;
    } else {
        $c = $b;  $ca = 0;  $cb = 1;
        $d = $a;  $da = 1;  $db = 0;
    }
    my ($q, $r);
    for (;;) {
        $q = $c / $d;  # integer division because we're using bigint
        #print "Q is $q\n";
        $r = $c % $d;
        #print "R is $r\n";
        last if $r == 0;
        #print "CA = $ca\n";
        #print "DA = $da\n";
        #print "CB = $cb\n";
        #print "DB = $db\n";
        my $ra = $ca - $da * $q;
        my $rb = $cb - $db * $q;
        #print "RA = $ra\n";
        #print "RB = $rb\n";
        $c = $d;
        $ca = $da;
        $cb = $db;
        $d = $r;
        $da = $ra;
        $db = $rb;
    }
    return ($d, $da, $db);
}