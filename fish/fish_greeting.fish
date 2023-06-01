function fish_greeting
  echo
  for c in black red green yellow blue magenta cyan white
    set_color $c
    echo -n " "
    set_color br$c
    echo -n " "
  end
  echo
end
