#!/usr/bin/perl

use strict;
use warnings;

my $fh;

if (open $fh, ">", "tempmenu.json") {
    print $fh q{[
        {
            "display": "Temp 1",
            "response": {
                "type": "BASH",
                "commands": [
                    "date",
                    "echo 'choice 1'",
                    "sleep 10"
                ]
            }
        },
        {
            "display": "Back",
            "response": {
                "type": "BACK"
            }
        },
        {
            "display": "Exit",
            "response": {
                "type": "EXIT"
            }
        }
    ]
};
    close $fh;
}
else {
    die "Cannot open tempname.json";
}

