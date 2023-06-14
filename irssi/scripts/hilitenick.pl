use strict;
use warnings;

our $VERSION = '0.4.2';
our %IRSSI = (
    authors     => 'Nei',
    contact     => 'Nei @ anti@conference.jabber.teamidiot.de',
    url         => "http://anti.teamidiot.de/",
    name        => 'colorize_nicks',
    description => 'Colourise mention of nicks in the message body.',
    license     => 'GNU GPLv2 or later',
   );

no warnings 'redefine';
use Irssi;

Irssi::theme_register([
    'hilitenick_loaded', '{perl HiliteNick}Loaded {comment $0}',
]);

my $irssi_mumbo = qr/\cD[`-i]|\cD[&-@\xff]./;
my $nickchar = qr/[\]\[[:alnum:]\\|`^{}_-]/;
my $nick_pat = qr/($nickchar+)/;
my @ignore_list;
my $colourer_script;

sub _find_colourer {
    my $colourer;
    unless ($colourer_script
    && ($colourer = "Irssi::Script::$colourer_script"->can('get_nick_color2'))) {
      for my $script (sort map { s/::$//r } keys %Irssi::Script::) {
        if ($colourer = "Irssi::Script::$script"->can('get_nick_color2')) {
          $colourer_script = $script;
    		  last;
	      }
  	  }
    }
    $colourer
}

sub _get_chanref {
    my ($dest) = @_;
    return unless $dest->{level} & MSGLEVEL_PUBLIC;
    return unless defined $dest->{target};
    return unless ref $dest->{server};
    $dest->{server}->channel_find($dest->{target})
}

sub _colourise_nicks {
    my ($dest, $chanref, $colourer, @nicks) = @_;

    my %nicks = map { $_->[0] => $colourer->($dest->{server}{tag}, $chanref->{name}, $_->[1], 1) }
    grep { defined }
    map { if (my $nr = $chanref->nick_find($_)) {
      [ $_ => $nr->{nick} ]
    } }
    keys %{ +{ map { $_ => undef } @nicks } };
    delete @nicks{ @ignore_list };

    my $nick_re = join '|', map { quotemeta } sort { length $b <=> length $a } grep { length $nicks{$_} } keys %nicks;

    (\%nicks, $nick_re)
}

sub _colourise_form {
    my ( $text,
    $skip,
    $nicks,
    $nick_re ) = @_;
    return if $skip < 0;

    my $repeat = Irssi::settings_get_bool('hilitenick_repeat_formats');

    my @forms = split /((?:$irssi_mumbo|\s|[.,*@%+&!#$()=~'";:?\/><]+(?=$irssi_mumbo|\s))+)/, $text, -1;
    my $ret = '';
    my $fmtstack = '';
    while (@forms) {
      my ($t, $form) = splice @forms, 0, 2;
      if ($skip > 0) {
        --$skip;
        $ret .= $t;
        $ret .= $form if defined $form;
        if ($repeat) {
          $fmtstack .= join '', $form =~ /$irssi_mumbo/g if defined $form;
          $fmtstack =~ s/\cDe//g;
        }
      }
      elsif (length $nick_re
      && $t =~ s/((?:^|\s)\W{0,3}?)(?<!$nickchar|')($nick_re)(?!$nickchar)/$1$nicks->{$2}$2\cDg$fmtstack/g) {
        $ret .= "$t\cDg$fmtstack";
        $ret .= $form if defined $form;
        $fmtstack .= join '', $form =~ /$irssi_mumbo/g if defined $form;
        $fmtstack =~ s/\cDe//g;
      }
      else {
        $ret .= $t;
        $ret .= $form if defined $form;
      }
    }

    $ret
}

# TXT_OWN_MSG,                                         server->nick, msg, nickmode
# TXT_OWN_MSG_CHANNEL,                                 server->nick, target, msg, nickmode
# TXT_PUBMSG_HILIGHT,                                  color, printnick, msg, nickmode
# TXT_PUBMSG_HILIGHT_CHANNEL,                          color, printnick, target, msg, nickmode
# for_me ? TXT_PUBMSG_ME : TXT_PUBMSG,                 printnick, msg, nickmode
# for_me ? TXT_PUBMSG_ME_CHANNEL : TXT_PUBMSG_CHANNEL, printnick, target, msg, nickmode
sub prt_format_issue {
    my ( $theme,
      $module,
      $dest,
      $format,
      @args
    ) = @_;
    my $chanref = _get_chanref($dest);
    return unless $chanref;
    my $colourer = _find_colourer();
    return unless $colourer;

    my $arg = 1;
    $arg++ if $format =~ /_channel/;
    $arg++ if $format =~ /_hilight/;
    return unless @args > $arg;
    
    utf8::decode($args[$arg]);
    my $text = $args[$arg];
    my $stripped = Irssi::strip_codes($text);

    utf8::decode($stripped);
    my ($nicks, $nick_re) = _colourise_nicks($dest, $chanref, $colourer, $stripped =~ /$nick_pat/g);
    return unless $nicks;

    $args[$arg] = _colourise_form($text, 0, $nicks, $nick_re);
    Irssi::signal_continue($theme, $module, $dest, $format, @args)
	    if defined $args[$arg] && $args[$arg] ne $text;
}

sub setup_changed {
    @ignore_list = split /\s+|,/, Irssi::settings_get_str('hilitenick_ignore_list');
}

sub init {
    setup_changed();
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'hilitenick_loaded', $VERSION);
}

Irssi::signal_add('print format' => 'prt_format_issue');
Irssi::signal_add_last('setup changed' => 'setup_changed');

Irssi::settings_add_str('hilitenick', 'hilitenick_ignore_list' => '');
Irssi::settings_add_bool('hilitenick', 'hilitenick_repeat_formats' => 0);

init();
