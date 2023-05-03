function fish_prompt
  set -l last $status
  set -l yellow (set_color yellow)
  set -l red (set_color red)
  set -l green (set_color green)
  set -l blue (set_color blue)
  set -l normal (set_color normal)

  echo ""

  if test (id -u $USER) = 0
    echo -n -s $yellow "☢ "
  end

  echo -n -s $blue (pwd | sed "s:^$HOME:~:")
  echo ""

  if test $last = 0
    echo -n $green
  else
    echo -n $red
  end

  echo -n "❯" $normal
end
