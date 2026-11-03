# Temporary: hunting occasional 2-5 s shell starts. Every interactive zsh logs
# its startup time to ~/.cache/zsh-startup.log; starts over 1.5 s also save a
# zprof breakdown in ~/.cache/zsh-slow/. Remove once the cause is found.
{ lib, ... }:
{
  programs.zsh = {
    envExtra = ''
      [[ -o interactive ]] && { zmodload zsh/datetime zsh/zprof; typeset -g __zsh_start=$EPOCHREALTIME; }
    '';

    initContent = lib.mkOrder 2000 ''
      if (( ''${+__zsh_start} )); then
        () {
          local took=$(( EPOCHREALTIME - __zsh_start ))
          print -r -- "$(strftime '%F %T' $EPOCHSECONDS) ''${(l:6:)$(printf %.2f $took)}s tty=$TTY term=$TERM" >> ~/.cache/zsh-startup.log
          if (( took > 1.5 )); then
            mkdir -p ~/.cache/zsh-slow
            zprof > ~/.cache/zsh-slow/$(strftime '%F_%H-%M-%S' $EPOCHSECONDS).txt
          fi
        }
        unset __zsh_start
        zmodload -u zsh/zprof
      fi
    '';
  };
}
