# ipAnon
This is a powershell script to anonomize a list of IP addresses.

## Functions
The script takes the following mandatory parameters:
* -keyFile "[location of key file]"
* -inputFile "[location of input file]"
* -privFrom "[IP range start]"
* -privTo "[IP range stop]"


The script will see if a key file (key.txt) exists. If this exists, it will load the key-value pairs into the $hash hashtable. This scripts also takes an input file (ip.txt) and reads the IP addresses located within. Next the script will loop through these IP addresses and check if a $key with this "name" already exist in the $hash hashtable, if they do the $ip will be added to the output with the existing $value. If the $ip does not exist as a key it will be randomized and added to the $hash.

The randomIP function will check if an $ip is in the given "private" ip range, if this is the case it will get a random IP starting with 1. if the $ip is not in the private range it will get an random IP with a starting number between 2-254.

## Constraints
* The input file consists of a list of (one per line) ip addresses (example in [ip.txt](ip.txt))


## Example
```powershell
.\ipAnon.ps1 -keyFile .\key.txt -inputFile .\ip.txt -privFrom "10.0.0.0" -privTo "10.0.50.255"
```