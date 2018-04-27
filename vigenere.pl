#!/usr/bin/perl -w
use strict;

# Vigenere cipher toolkit. Encrypt and Decrypt.
# Cracking not included.
# 

my $plaintext    = "A long string of text to encrypt for fun, not for any really other reason."; # By definiton, letters only.
my $key          = 'This is some key';        # By definition, letters only.
my $ciphertext;
my $derived_plaintext;

# For convenience, do the work in lowercase...
$plaintext = lc($plaintext);
$key       = lc($key);

# By definition, only encipher letters, and only use letters in the key...
$plaintext =~ s/[^a-z]//g;
$key       =~ s/[^a-z]//g;
if(length($key) < 1){
    die "Key must contain at least one letter. A single letter key makes it a monoalphabetic cipher!!\n";
}

print "plaintext is [$plaintext]\n\n";
$ciphertext           = encrypt_string($plaintext, $key);
$derived_plaintext    = decrypt_string($ciphertext, $key );

print "Original plaintext  :$plaintext\n";
print "Ciphertext          :$ciphertext\n";
print "Recreated plaintext :$derived_plaintext\n";

sub encrypt_string{
    # encrypts a full string of plaintext, given the plaintext and the key.
    # returns the encrypted string.
    my ($plaintext, $key) = @_;
    my $ciphertext;
    $key = $key x (length($plaintext) / length($key) + 1);
    print "Key is now: $key\n";
    for(my $i=0; $i<length($plaintext); $i++ ){
        $ciphertext .= encrypt_letter((substr($plaintext,$i,1)),  (substr($key,$i,1)));
        print "Ciphertext is now: $ciphertext\n";
    }
    return $ciphertext;
}

sub decrypt_string{
    # decrypts a full string of ciphertext, given the ciphertext and the key.
    # returns the plaintext string.
    my ($ciphertext, $key) = @_;
    my $plaintext;
    $key = $key x (length($ciphertext) / length($key) + 1);
    for(my $i=0; $i<length($ciphertext); $i++ ){
        $plaintext .=
            decrypt_letter((substr($ciphertext,$i,1)),  (substr($key,$i,1)));
    }
    return $plaintext;
}


sub encrypt_letter{
    # encrypts a single letter of plaintext, given the plaintext
    # letter and the key to use for that letter's position.
    # The key is the first letter of the row to look in.
    # Using the Vigenere Square (of course)
    my ($plain, $row) = @_;
    my $cipher;
    # in row n, ciphertext is plaintext + n, mod 26.
    $row     = ord(lc($row))   - ord('a');    # enable mod 26. We use ord('a') as our anchor to 0 (so B=1, etc)
    print ord(lc($row)) . "\n";
    $plain  = ord(lc($plain)) - ord('a');    # enable mod 26
    print "Plain is: $plain\n";
    $cipher = ($plain + $row) % 26;
    print "Cipher is: $cipher\n";
    
    $cipher = chr($cipher + ord('a'));
    print "Cipher is: $cipher\n";

    return uc($cipher);    #ciphertext in uppercase
}

sub decrypt_letter{
    # decrypts a single letter of ciphertext, given the ciphertext
    # letter and the key to use for that letter's position.
    # The key is the first letter of the row to look in.
    my ($cipher, $row) = @_;
    my $plain;
    # in row n, plaintext is ciphertext - n, mod 26.
    $row     = ord(lc($row))    - ord('a');    # enable mod 26
    $cipher = ord(lc($cipher)) - ord('a');    # enable mod 26
    $plain  = ($cipher - $row) % 26;
    
    $plain = chr($plain + ord('a'));

    return lc($plain);    #plaintext in lowercase
}