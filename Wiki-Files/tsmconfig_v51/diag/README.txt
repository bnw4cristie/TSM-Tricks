CAUTION: The script cleanupserversetup.pl is destructive, and will completely remove a TSM server
         and all stored data. 

The script cleanupserversetup.pl can be used to completely clenaup and remove a TSM server that was
configured using the TSM blueprint configuration script.  This script is destructive and should only
be used for troubleshooting purposes during initial testing of the blueprint script.  This script
depends on the existence of the file named serversetupstatefileforcleanup.txt which is generated
by the script TSMserverconfig.pl.

To use this script:

1) Edit cleanupserversetup.pl and comment-out the exit on the first line
2) Copy cleanupserversetup.pl into the same folder where TSMserverconfig.pl is located
3) perl TSMserverconfig.pl
4) perl cleanupserversetup.pl 