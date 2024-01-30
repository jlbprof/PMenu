package PMenu;

use strict;
use warnings;

use Curses;
use File::Temp;
use File::chdir;

use Cpanel::JSON::XS;
use Path::Tiny;

# Used during debugging, not needed for operations

use Data::Dumper;
use Data::HexDump;

our $max_rows;
our $max_cols;
our $win;

sub _load_menu {
    my ($fname) = @_;

    my $json_obj = Cpanel::JSON::XS->new->ascii->pretty->allow_nonref;
    my $json_raw = Path::Tiny::path ($fname)->slurp ();
    my $menu = $json_obj->decode ($json_raw);

    return $menu;
}

sub init {
    if (!$win) {
        $win = new Curses;
    }

    if (!$max_rows || $max_cols) {
        $win->getmaxyx ($max_rows, $max_cols);
    }

    return _load_menu ("pmenu.json");
}

sub cleanup {
    Curses::endwin ();
    print "\n\n";
}

sub hard_exit {
    my ($val) = @_;

    $val ||= 0;

    if ($win) {
        cleanup ();
        exit $val;
    }

    exit $val;
}

sub _die_if_not_initted {
    die "PMenu has not been initialized\n" if (!$win);
    die "PMenu has not been initialized\n" if (!$max_rows || !$max_cols);
}

sub get_key {
    my ($win) = @_;

    _die_if_not_initted ();

    my $key = $win->getch ();
    if ($key eq chr(0x1b)) {
        # Read 2 more
        my $chr1;
        my $chr2;

        $chr1 = $win->getch ();
        $chr2 = $win->getch ();

        return Curses::KEY_DOWN if ($chr1 eq chr(0x5B) && $chr2 eq chr(0x42));
        return Curses::KEY_UP if ($chr1 eq chr(0x5B) && $chr2 eq chr(0x41));

        $win->addstr ($max_rows - 1, 0, "Invalid Key Stroke");
        $win->refresh ();
        sleep (2);
        $win->addstr ($max_rows - 1, 0, "                  ");
        $win->refresh ();

        return -1;
    }

    return $key;
}

sub _display_menu {
    my ($menu_ar, $current_item) = @_;

    $win->clear ();

    my $num_choices = @{ $menu_ar };
    my $max_width = 0;
    foreach my $choice_hr (@{ $menu_ar })
    {
        my $len = length ($choice_hr->{display});
        $max_width = $len if $len > $max_width;
    }

    my $row = int (($max_rows - $num_choices)/2);
    my $col = int (($max_cols - $max_width)/2);

    foreach my $i (0 .. ($num_choices - 1)) {
        my $r = $row + $i;
        my $choice_hr = $menu_ar->[$i];

        my $chosen = 0;
        $chosen = 1 if $i == $current_item;

        $win->attron (Curses::A_REVERSE) if $chosen;
        $win->addstr ($r, $col, $choice_hr->{display});
        $win->attroff (Curses::A_REVERSE) if $chosen;
    }

    $win->refresh ();
}

sub _exec_script {
    my ($shebang, $cmds) = @_;

    my ($fh, $filename) = File::Temp::tempfile ("pmenu_XXXXX", SUFFIX => ".sh");
    print $fh "$shebang\n";
    foreach my $cmd (@{ $cmds }) {
        print $fh "$cmd\n";
    }
    close $fh;

    system ('chmod', 'a+x', $filename);
    system ("./$filename");

    unlink $filename;

    return 0;
}

sub _action {
    my ($full_menu_ar, $choice_hr) = @_;

    cleanup ();

    print "***************** Taking action for " . $choice_hr->{display} . "\n\n";

    my $type = $choice_hr->{response}->{type};
    if ($type eq "BASH") {
        _exec_script ("#!/bin/bash", $choice_hr->{response}->{commands});
        return 0;
    }
    elsif ($type eq "EXEC") {
        my $cmd = $choice_hr->{response}->{command};
        exec ($cmd);
    }
    elsif ($type eq "MENU") {
        my $menu_name = $choice_hr->{response}->{menu};
        die "Invalid Menu Name :$menu_name:\n" if (!exists ($full_menu_ar->{$menu_name}));

        menu ($full_menu_ar, $menu_name);
        return 0;
    }
    elsif ($type eq "TEMPMENU") {
        _exec_script ("#!/bin/bash", $choice_hr->{response}->{commands});

        die "tempmenu.json does not exist" if (!-r "tempmenu.json");

        my $tmenu = _load_menu ("tempmenu.json");
        unlink "tempmenu.json";

        $full_menu_ar->{tempmenu} = $tmenu;

        menu ($full_menu_ar, "tempmenu");
        delete $full_menu_ar->{tempmenu};
    
        return 0;
    }
    elsif ($type eq "BACK") {
        return -1;
    }
    elsif ($type eq "EXIT") {
        exit (0);
    }
    else {
        print "Invalid Response Type :$type:\n";
        exit 1;
    }

    return 0;
}

sub menu {
    my ($full_menu_ar, $menu_name) = @_;

    init ();

    my $menu_ar = $full_menu_ar->{$menu_name};
    my $num_choices = @{ $menu_ar };

    my $current_item = 0;

    while (1) {
        _display_menu ($menu_ar, $current_item);

        my $key;
        $key = get_key ($win);

        if ($key eq Curses::KEY_UP) {
            $current_item--;
            $current_item = $num_choices - 1 if ($current_item < 0);
        }
        elsif ($key eq Curses::KEY_DOWN) {
            $current_item++;
            $current_item = 0 if ($current_item >= $num_choices);
        }
        elsif ($key eq "\n") {
            my $chosen_hr = $menu_ar->[$current_item];
            return if (_action ($full_menu_ar, $chosen_hr) == -1);
        }
    }
}

1;

__END__


