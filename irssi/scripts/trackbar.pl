## Usage:
#
#  The script works right out of the box, but if you want you can change
#  the working by /set'ing the following variables:
#
#    Setting:     trackbar_style
#    Description: This setting will be the color of your trackbar line.
#                 By default the value will be '%K', only Irssi color
#                 formats are allowed. If you don't know the color formats
#                 by heart, you can take a look at the formats documentation.
#                 You will find the proper docs on http://www.irssi.org/docs.
#
#    Setting:     trackbar_string
#    Description: This is the string that your line will display. This can
#                 be multiple characters or just one. For example: '~-~-'
#                 The default setting is '-'.
#                 Here are some unicode characters you can try:
#                     "───" => U+2500 => a line
#                     "═══" => U+2550 => a double line
#                     "━━━" => U+2501 => a wide line
#                     "▭  " => U+25ad => a white rectangle
#
#    Setting:     trackbar_ignore
#    Description: A list of windows where no trackbar should be printed
#
#    Setting:     trackbar_require_seen
#    Description: Only clear the trackbar if it has been scrolled to.
#
#    Command:     /trackbar, /trackbar goto
#    Description: Jump to where the trackbar is, to pick up reading
#
#    Command:     /trackbar keep
#    Description: Keep this window's trackbar where it is the next time
#                 you switch windows (then this flag is cleared again)
#
#    Command:     /trackbar mark
#    Description: Remove the old trackbar and mark the bottom of this
#                 window with a new trackbar
#
#    Command:     /trackbar markvisible
#    Description: Like mark for all visible windows
#
#    Command:     /trackbar markall
#    Description: Like mark for all windows
#
#    Command:     /trackbar remove
#    Description: Remove this window's trackbar
#
#    Command:     /trackbar removeall
#    Description: Remove all windows' trackbars
#
#    Command:     /trackbar redraw
#    Description: Force redraw of trackbars

use strict;
use warnings;
use vars qw($VERSION %IRSSI);

$VERSION = "2.9.1";

%IRSSI = (
    authors     => "Peter 'kinlo' Leurs, Uwe Dudenhoeffer, Michiel Holtkamp, Nico R. Wohlgemuth, Geert Hauwaerts",
    contact     => 'peter@pfoe.be',
    patchers    => 'Johan Kiviniemi (UTF-8), Uwe Dudenhoeffer (on-upgrade-remove-line)',
    name        => 'trackbar',
    description => 'Shows a bar where you have last read a window.',
    license     => 'GNU General Public License',
    url         => 'http://www.pfoe.be/~peter/trackbar/',
    commands    => 'trackbar',
);

use Irssi;
use Irssi::TextUI;
use Encode;

use POSIX qw(strftime);

Irssi::theme_register([
    'trackbar_loaded',      '{perl Trackbar}Loaded {comment $0}',
    'trackbar_all_removed', '{perl Trackbar}All the trackbars have been removed',
    'trackbar_not_found',   '{perl Trackbar}No trackbar found in this window',
]);

sub trackbar_help {
    my ($args) = @_;
    if ($args =~ /^trackbar *$/i) {
        print CLIENTCRAP <<HELP
%9Syntax:%9

TRACKBAR
TRACKBAR GOTO
TRACKBAR KEEP
TRACKBAR MARK
TRACKBAR MARKVISIBLE
TRACKBAR MARKALL
TRACKBAR REMOVE
TRACKBAR REMOVEALL
TRACKBAR REDRAW

%9Parameters:%9

    GOTO:        Jump to where the trackbar is, to pick up reading
    KEEP:        Keep this window's trackbar where it is the next time
                 you switch windows (then this flag is cleared again)
    MARK:        Remove the old trackbar and mark the bottom of this
                 window with a new trackbar
    MARKVISIBLE: Like mark for all visible windows
    MARKALL:     Like mark for all windows
    REMOVE:      Remove this window's trackbar
    REMOVEALL:   Remove all windows' trackbars
    REDRAW:      Force redraw of trackbars

%9Description:%9

    Manage a trackbar. Without arguments, it will scroll up to the trackbar.

%9Examples:%9

    /TRACKBAR MARK
    /TRACKBAR REMOVE
HELP
    }
}

sub is_utf8 {
    lc Irssi::settings_get_str('term_charset') eq 'utf-8'
}

my (%config, %keep_trackbar, %unseen_trackbar);

sub remove_one_trackbar {
    my $win = shift;
    my $view = shift || $win->view;
    my $line = $view->get_bookmark('trackbar');
    if (defined $line) {
        my $bottom = $view->{bottom};
        $view->remove_line($line);
        $win->command('^scrollback end') if $bottom && !$win->view->{bottom};
        $view->redraw;
    }
}

sub add_one_trackbar_pt1 {
    my $win = shift;
    my $view = shift || $win->view;

    my $last_cur_line = ($view->{buffer}{cur_line}||+{})->{_irssi};
    $win->print(line($win->{width}), MSGLEVEL_NEVER);

    my $cur_line = ($win->view->{buffer}{cur_line}||+{})->{_irssi}; # get a fresh buffer

    ($last_cur_line//'') ne ($cur_line//'') # printing was successful
}

sub add_one_trackbar_pt2 {
    my $win = shift;
    my $view = $win->view;

    $view->set_bookmark_bottom('trackbar');
    $unseen_trackbar{ $win->{_irssi} } = 1;
    Irssi::signal_emit("window trackbar added", $win);
    $view->redraw;
}

sub update_one_trackbar {
    my $win = shift;
    my $view = shift || $win->view;
    my $force = shift;
    my $ignored = win_ignored($win, $view);
    my $success;

    $success = add_one_trackbar_pt1($win, $view) ? 1 : 0
    if $force || !$ignored;

    remove_one_trackbar($win, $view)
    if ( $success || !defined $success ) && ( $force || !defined $force || !$ignored );

    add_one_trackbar_pt2($win)
    if $success;
}

sub win_ignored {
    my $win = shift;
    my $view = shift || $win->view;
    return 1 unless $view->{buffer}{lines_count};
    no warnings 'uninitialized';
    return 1 if grep { $win->{name} eq $_ || $win->{refnum} eq $_
			   || $win->get_active_name eq $_ } @{ $config{ignore_windows} };
    return 0;
}

sub sig_window_changed {
    my ($newwindow, $oldwindow) = @_;
    return unless $oldwindow;
    redraw_one_trackbar($newwindow);
    trackbar_update_seen($newwindow);
    return if delete $keep_trackbar{ $oldwindow->{_irssi} };
    trackbar_update_seen($oldwindow);
    return if $config{require_seen} && $unseen_trackbar{ $oldwindow->{_irssi } };
    update_one_trackbar($oldwindow, undef, 0);
}

sub trackbar_update_seen {
    my $win = shift;
    return unless $win;
    return unless $unseen_trackbar{ $win->{_irssi} };

    my $view = $win->view;
    my $line = $view->get_bookmark('trackbar');
    unless ($line) {
        delete $unseen_trackbar{ $win->{_irssi} };
        Irssi::signal_emit("window trackbar seen", $win);
        return;
    }
    my $startline = $view->{startline};
    return unless $startline;

    if ($startline->{info}{time} < $line->{info}{time}
            || $startline->{_irssi} == $line->{_irssi}) {
        delete $unseen_trackbar{ $win->{_irssi} };
        Irssi::signal_emit("window trackbar seen", $win);
    }
}

sub screen_length;
{ local $@;
  eval { require Text::CharWidth; };
  unless ($@) {
      *screen_length = sub { Text::CharWidth::mbswidth($_[0]) };
  }
  else {
      *screen_length = sub {
          my $temp = shift;
          Encode::_utf8_on($temp) if is_utf8();
          length($temp)
      };
  }
}

{ my %strip_table = (
    (map { $_ => '' } (split //, '04261537' .  'kbgcrmyw' . 'KBGCRMYW' . 'U9_8I:|FnN>#[' . 'pP')),
    (map { $_ => $_ } (split //, '{}%')),
   );
  sub c_length {
      my $o = Irssi::strip_codes($_[0]);
      $o =~ s/(%(%|Z.{6}|z.{6}|X..|x..|.))/exists $strip_table{$2} ? $strip_table{$2} :
          $2 =~ m{x(?:0[a-f]|[1-6][0-9a-z]|7[a-x])|z[0-9a-f]{6}}i ? '' : $1/gex;
      screen_length($o)
  }
}

sub line {
    my ($width, $time)  = @_;
    my $string = $config{string};
    $string = ' ' unless length $string;
    $time ||= time;

    Encode::_utf8_on($string) if is_utf8();
    my $length = c_length($string);
    my $format = '';
    my $times = $width / $length;
    $times += 1 if $times != int $times;
    my $style = "$config{style}";
    Encode::_utf8_on($style) if is_utf8();
    $format .= $style;
    $width -= c_length($format);
    $string x= $times;
    chop $string while length $string && c_length($string) > $width;
    return $format . $string;
}

sub remove_all_trackbars {
    for my $window (Irssi::windows) {
        next unless ref $window;
        remove_one_trackbar($window);
    }
}

sub UNLOAD {
    remove_all_trackbars();
}

sub redraw_one_trackbar {
    my $win = shift;
    my $view = $win->view;
    my $line = $view->get_bookmark('trackbar');
    return unless $line;
    my $bottom = $view->{bottom};
    $win->print_after($line, MSGLEVEL_NEVER, line($win->{width}, $line->{info}{time}),
		      $line->{info}{time});
    $view->set_bookmark('trackbar', $win->last_line_insert);
    $view->remove_line($line);
    $win->command('^scrollback end') if $bottom && !$win->view->{bottom};
    $view->redraw;
}

sub trackbar_redraw {
    for my $win (Irssi::windows) {
        next unless ref $win;
        redraw_one_trackbar($win);
    }
}

sub trackbar_goto {
    my $win = Irssi::active_win;
    my $line = $win->view->get_bookmark('trackbar');

    if ($line) {
        $win->command("scrollback goto ". strftime("%d %H:%M:%S", localtime($line->{info}{time})));
    } else {
        $win->printformat(MSGLEVEL_CLIENTCRAP, 'trackbar_not_found');
    }
}

sub trackbar_mark {
    update_one_trackbar(Irssi::active_win, undef, 1);
}

sub trackbar_markall {
    for my $window (Irssi::windows) {
        next unless ref $window;
        update_one_trackbar($window);
    }
}

sub signal_stop {
    Irssi::signal_stop;
}

sub trackbar_markvisible {
    my @wins = Irssi::windows;
    my $awin =
        my $bwin = Irssi::active_win;
    my $awin_counter = 0;
    Irssi::signal_add_priority('window changed' => 'signal_stop', -99);
    do {
        Irssi::active_win->command('window up');
        $awin = Irssi::active_win;
        update_one_trackbar($awin);
        ++$awin_counter;
    } until ($awin->{refnum} == $bwin->{refnum} || $awin_counter >= @wins);
    Irssi::signal_remove('window changed' => 'signal_stop');
}

sub trackbar_remove {
    remove_one_trackbar(Irssi::active_win);
}

sub trackbar_removeall {
    remove_all_trackbars();
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'trackbar_all_removed');
}

sub trackbar_keep {
    $keep_trackbar{ Irssi::active_win->{_irssi} } = 1;
}

sub trackbar_runsub {
    my ($data, $server, $item) = @_;
    $data =~ s/\s+$//g;

    if ($data) {
        Irssi::command_runsub('trackbar', $data, $server, $item);
    } else {
        trackbar_goto();
    }
}

sub update_config {
    $config{style} = Irssi::settings_get_str('trackbar_style');
    $config{string} = Irssi::settings_get_str('trackbar_string');
    $config{require_seen} = Irssi::settings_get_bool('trackbar_require_seen');
    $config{ignore_windows} = [ split /[,\s]+/, Irssi::settings_get_str('trackbar_ignore') ];
    trackbar_redraw();
}

Irssi::settings_add_str('trackbar', 'trackbar_string', is_utf8() ? "━" : '-');
Irssi::settings_add_str('trackbar', 'trackbar_style', '%K');
Irssi::settings_add_str('trackbar', 'trackbar_ignore', 'aspell');
Irssi::settings_add_bool('trackbar', 'trackbar_require_seen', 0);

update_config();

Irssi::signal_add_last( 'mainwindow resized'    => 'trackbar_redraw');
Irssi::signal_register({'window trackbar added' => [qw/Irssi::UI::Window/]});
Irssi::signal_register({'window trackbar seen'  => [qw/Irssi::UI::Window/]});
Irssi::signal_register({'gui page scrolled'     => [qw/Irssi::UI::Window/]});
Irssi::signal_add_last('gui page scrolled'      => 'trackbar_update_seen');
Irssi::signal_add('setup changed'               => 'update_config');
Irssi::signal_add_priority('session save'       => 'remove_all_trackbars', Irssi::SIGNAL_PRIORITY_HIGH-1);
Irssi::signal_add('window changed'              => 'sig_window_changed');

Irssi::command_bind('trackbar goto'        => 'trackbar_goto');
Irssi::command_bind('trackbar keep'        => 'trackbar_keep');
Irssi::command_bind('trackbar mark'        => 'trackbar_mark');
Irssi::command_bind('trackbar markvisible' => 'trackbar_markvisible');
Irssi::command_bind('trackbar markall'     => 'trackbar_markall');
Irssi::command_bind('trackbar remove'      => 'trackbar_remove');
Irssi::command_bind('trackbar removeall'   => 'trackbar_removeall');
Irssi::command_bind('trackbar redraw'      => 'trackbar_redraw');
Irssi::command_bind('trackbar'             => 'trackbar_runsub');
Irssi::command_bind_last('help'            => 'trackbar_help');

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'trackbar_loaded', $VERSION);

{ package Irssi::Nick }
