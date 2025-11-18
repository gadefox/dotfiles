use strict;
use warnings;

use vars qw($VERSION %IRSSI);
use Irssi;
use Irssi::TextUI;
use Encode;
use Text::Aspell;

$VERSION = '0.9.2';
%IRSSI = (
    authors     => 'Jakub Wilk, Jakub Jankowski, Gabriel Pettier, Nei',
    name        => 'spellchecker',
    description => 'checks for spelling errors using Aspell',
    license     => 'GPLv2',
    url         => 'http://jwilk.net/software/irssi-spellcheck',
);

Irssi::theme_register([
  'aspell_loaded',    '{perl ASpell}Loaded {comment $0}',
  'aspell_result',    '%R󰓆 %|$0: %n$1',
  'aspell_empty',     '%R󰓆 $0: %nNo suggestions',
  'aspell_err_check', '{perlerror ASpell Error while spell-checking for $0}',
  'aspell_err_set',   '{perlerror ASpell Error while setting up spell-checker for $0}',
  'aspell_err_save',  '{perlerror ASpell Error while saving $0 dictionary}',
  'aspell_add_args',  '{perlwarn ASpell ASPELL_ADD <word>  add word(s) to personal dictionary}',
]);

my %speller;

sub aspell_setup
{
    my ($lang) = @_;
    my $speller = $speller{$lang};
    return $speller if defined $speller;
    $speller = Text::Aspell->new or return;
    $speller->set_option('lang', $lang) or return;
    $speller->set_option('sug-mode', 'fast') or return;
    $speller{$lang} = $speller;
    return $speller;
}

# add_rest means "add (whatever you chopped from the word before
# spell-checking it) to the suggestions returned"
sub aspell_check_word
{
    my ($langs, $word, $add_rest) = @_;
    my $win = Irssi::active_win();
    my $prefix = '';
    my $suffix = '';

    my @langs = split(/[+]/, $langs);
    for my $lang (@langs) {
        my $speller = aspell_setup($lang);
        if (not defined $speller) {
            $win->printformat(MSGLEVEL_CLIENTCRAP, 'aspell_err_set', $lang);
            return;
        }
    }

    return if $word =~ m{^/}; # looks like a path
    $word =~ s/^([[:punct:]]*)//; # strip leading punctuation characters
    $prefix = $1 if $add_rest;
    $word =~ s/([[:punct:]]*)$//; # ...and trailing ones, too
    $suffix = $1 if $add_rest;
    return if $word =~ m{^\w+://}; # looks like a URL
    return if $word =~ m{^[^@]+@[^@]+$}; # looks like an e-mail
    return if $word =~ m{^[[:digit:][:punct:]]+$}; # looks like a number

    my @result;
    for my $lang (@langs) {
        my $ok = $speller{$lang}->check($word);
        if (not defined $ok) {
            $win->printformat(MSGLEVEL_CLIENTCRAP, 'aspell_err_check', $lang);
            return;
        }
        if ($ok) {
            return;
        } else {
            push @result, map { "$prefix$_$suffix" } $speller{$lang}->suggest($word);
        }
    }
    return \@result;
}

sub _aspell_find_language
{
    my ($network, $target) = @_;
    return Irssi::settings_get_str('aspell_default') unless (defined $network && defined $target);

    # support !channels correctly
    $target = '!' . substr($target, 6) if ($target =~ /^\!/);

    # lowercase net/chan
    $network = lc($network);
    $target  = lc($target);

    # possible settings: network/channel/lang  or  channel/lang
    my @languages = split(/[ ,]+/, Irssi::settings_get_str('aspell_languages'));
    for my $langstr (@languages) {
        my ($t, $c, $l) = $langstr =~ m{^(?:([^/]+)/)?([^/]+)/([^/]+)/*$};
        $t //= $network;
        if (lc($c) eq $target and lc($t) eq $network) {
            return $l;
        }
    }

    # no match, use defaults
    return Irssi::settings_get_str('aspell_default');
}

sub aspell_find_language
{
    my ($win) = @_;
    return _aspell_find_language(
        $win->{active_server}->{tag},
        $win->{active}->{name}
    );
}

sub aspell_key_pressed
{
    my ($key) = @_;
    my $win = Irssi::active_win();

    my $correction_window;
    my $window_height;

    my $window_name = Irssi::settings_get_str('aspell_window_name');
    if ($window_name ne '') {
        $correction_window = Irssi::window_find_name($window_name);
        $window_height = Irssi::settings_get_str('aspell_window_height');
    }

    # hide correction window when message is sent
    if (chr($key) =~ /\A[\r\n]\z/ && $correction_window) {
        $correction_window->command("^window hide $window_name");
        if (Irssi->can('gui_input_clear_extents')) {
            Irssi::gui_input_clear_extents(0, 9999);
        }
    }

    # get current inputline
    my $inputline = Irssi::parse_special('$L');
    my $utf8 = lc Irssi::settings_get_str('term_charset') eq 'utf-8';
    if ($utf8) {
        Encode::_utf8_on($inputline);
    }

    # ensure that newly added characters are not colored
    # when correcting a colored word
    # FIXME: this works at EOL, but not elsewhere
    if (Irssi->can('gui_input_set_extent')) {
        Irssi::gui_input_set_extent(length $inputline, '%n');
    }

    # don't bother unless pressed key is space
    # or a terminal punctuation mark
    return unless grep { chr $key eq $_ } (' ', qw(. ? !));

    $inputline = substr $inputline, 0, Irssi::gui_input_get_pos();

    # check if inputline starts with any of cmdchars
    # we shouldn't spell-check commands
    # (except /SAY and /ME)
    my $cmdchars = Irssi::settings_get_str('cmdchars');
    my $re = qr{^(?:
        [\Q$cmdchars\E] (?i: say | me ) \s* \S |
        [^\Q$cmdchars\E]
    )}x;
    return if ($inputline !~ $re);

    # get last bit from the inputline
    my ($word) = $inputline =~ /\s*(\S+)\s*$/;
    defined $word or return;

    # remove color from the last word
    # (we will add it back later if needed)
    my $start = $-[1];
    if (Irssi->can('gui_input_clear_extents')) {
        Irssi::gui_input_clear_extents($start, length $word);
    }

    my $lang = aspell_find_language($win);

    return if $lang eq 'und';

    my $suggestions = aspell_check_word($lang, $word, 0);

    return unless defined $suggestions;

    # strip leading and trailing punctuation
    $word =~ s/^([[:punct:]]+)// and $start += length $1;
    $word =~ s/[[:punct:]]+$//;

    # add color to the misspelled word
    my $color = Irssi::settings_get_str('aspell_input_color');
    if ($color && Irssi->can('gui_input_set_extents')) {
        Irssi::gui_input_set_extents($start, length $word, $color, '%n');
    }

    # show corrections window if hidden
    if ($correction_window) {
        $win->command("^window show $window_name");
        $correction_window->command('^window stick off');
        $win->set_active;
        $correction_window->command("window size $window_height");
    } else {
        $correction_window = $win;
    }

    # we found a mistake, print suggestions
    $word =~ s/%/%%/g;
    if (scalar @$suggestions > 0) {
        if ($utf8) {
            Encode::_utf8_on($_) for @$suggestions;
        }
        $correction_window->printformat(MSGLEVEL_NEVER, 'aspell_result', $word, join(', ', @$suggestions));
    } else {
        $correction_window->printformat(MSGLEVEL_NEVER, 'aspell_empty', $word);
    }

    return;
}

sub aspell_complete_word
{
    my ($complist, $win, $word, $lstart, $wantspace) = @_;
    my $lang = aspell_find_language($win);

    return if $lang eq 'und';

    # add suggestions to the completion list
    my $suggestions = aspell_check_word($lang, $word, 1);
    push(@$complist, @$suggestions) if defined $suggestions;

    return;
}

sub aspell_add_word
{
    my ($cmd_line, $server, $win_item) = @_;
    my $win = Irssi::active_win();
    my @args = split(' ', $cmd_line);

    if (@args <= 0) {
        $win->printformat(MSGLEVEL_CLIENTCRAP, 'aspell_add_args');
        return;
    }

    my $lang = aspell_find_language($win);

    my $speller = aspell_setup($lang);
    if (not defined $speller) {
        $win->printformat(MSGLEVEL_CLIENTCRAP, 'aspell_err_set', $lang);
        return;
    }

    $win->print("Adding to $lang dictionary: @args");
    for my $word (@args) {
        $speller{$lang}->add_to_personal($word);
    }
    my $ok = $speller{$lang}->save_all_word_lists();
    if (not $ok) {
        $win->printformat(MSGLEVEL_CLIENTCRAP, 'aspell_err_save', $lang);
    }

    return;
}

Irssi::command_bind('aspell_add', 'aspell_add_word');

Irssi::settings_add_str( 'aspell', 'aspell_default', 'en_US');
Irssi::settings_add_str( 'aspell', 'aspell_languages', '');
Irssi::settings_add_str( 'aspell', 'aspell_input_color', '%R');
Irssi::settings_add_str( 'aspell', 'aspell_window_name', '(aspell)');
Irssi::settings_add_str( 'aspell', 'aspell_window_height', 10);

Irssi::signal_add_last('key word_completion', sub{aspell_key_pressed(ord '.')});
Irssi::signal_add_last('key word_completion_backward', sub{aspell_key_pressed(ord '.')});
Irssi::signal_add_last('gui key pressed', 'aspell_key_pressed');
Irssi::signal_add_last('complete word', 'aspell_complete_word');

Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'aspell_loaded', $VERSION);
