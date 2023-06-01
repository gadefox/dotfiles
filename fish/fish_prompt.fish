function fish_prompt
  set -l last $status
  echo

  if test (id -u $USER) = 0
    set_color yellow
    echo -n "☢ "
  end

  set_color blue
  echo (pwd | sed "s:^$HOME:~:")

  if test $last = 0
    set_color green
  else
    set_color red
  end

  echo -n "❯ "
  set_color normal
end
