use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

$VERSION = "1.0.1";
%IRSSI = (
	"authors"       => "Mantis",
	"contact"       => "mantis\@inta-link.com",
	"name"          => "highlite",
	"description"   => "shows events happening in all channels you are in that may concern you",
	"url"           => "http://www.inta-link.com/",
	"license"       => "GNU GPL v2",
);

Irssi::theme_register([
  'crap_loaded', '{perl Crap}Loaded {comment $0}',
  'crap_join',   '{line_start}{channick_hilight $0} {chanhost_hilight $1} has joined {channel $2}',
  'crap_part',   '{line_start}{channick $0} {chanhost $1} has left {channel $2} {reason $3}',
  'crap_quit',   '{line_start}{channick $0} {chanhost $1} has quit {reason $2}',
  'crap_topic',  '{line_start}{nick $0} changed the topic of {channel $1} to: $2',
  'crap_nick',   '{line_start}{channick $0} is now known as {channick_hilight $1}',
  'crap_kick',   '{line_start}{channick $0} was kicked from {channel $1} by {nick $2} {reason $3}',
]);

sub crap_window
{
  my $window_name = Irssi::settings_get_str('crap_window_name');
  if ($window_name ne '') {
    return Irssi::window_find_name($window_name);
  }
}

sub crap_join
{
  my ($server, $channel, $nick, $host) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_join', $nick, $host, $channel) if ($window);
}

sub crap_part
{
  my ($server, $channel, $nick, $host, $reason) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_part', $nick, $host, $channel, $reason) if ($window);
}

sub crap_quit
{
  my ($server, $nick, $host, $reason) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_quit', $nick, $host, $reason) if ($window);
}

sub crap_topic
{
  my ($server, $channel, $topicmsg, $nick) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_topic', $nick, $channel, $topicmsg) if ($window);
}

sub crap_nick
{
  my ($server, $nick, $old_nick) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_nick', $old_nick, $nick) if ($window);
}

sub crap_kick
{
  my ($server, $channel, $kicked, $nick, $host, $reason) = @_;
  my $window = crap_window;

  $window->printformat(MSGLEVEL_CLIENTCRAP, 'crap_kick', $kicked, $channel, $nick, $reason) if ($window);
}

# sub sig_win_created
# {
#   my ($newwindow) = @_;
#   #  $newwindow->command("^window hidelevel JOINS PARTS QUITS");
#   $newwindow->print("name", MSGLEVEL_CLIENTCRAP);
# }
#
Irssi::signal_add({
  'message join'  => 'crap_join',
  'message part'  => 'crap_part',
  'message quit'  => 'crap_quit',
  'message topic' => 'crap_topic',
  'message nick'  => 'crap_nick',
  'message kick'  => 'crap_kick',
  #  'window created' => 'sig_win_created'
});

Irssi::settings_add_str( 'crap', 'crap_window_name', '(crap)');

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'crap_loaded', $VERSION);
