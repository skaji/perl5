# Things to Remember

* JSON::PP 2.27300 for perl 5.8.6
* Pod::Usage 1.33 for perl 5.8.6
* Getopt::Long 2.39 for getoptionsfromarray

# is_insensitive_fs

From Module::ScanDeps
```perl
use constant is_insensitive_fs => (
    -s $0
        and (-s lc($0) || -1) == (-s uc($0) || -1)
        and (-s lc($0) || -1) == -s $0
);
```
