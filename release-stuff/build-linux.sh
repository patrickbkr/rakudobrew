#!/usr/bin/env bash

set -e

# Sourced from https://stackoverflow.com/a/29835459/1975049
rreadlink() (
  target=$1 fname= targetDir= CDPATH=
  { \unalias command; \unset -f command; } >/dev/null 2>&1
  [ -n "$ZSH_VERSION" ] && options[POSIX_BUILTINS]=on
  while :; do
      [ -L "$target" ] || [ -e "$target" ] || { command printf '%s\n' "ERROR: '$target' does not exist." >&2; return 1; }
      command cd "$(command dirname -- "$target")" || exit 1
      fname=$(command basename -- "$target")
      [ "$fname" = '/' ] && fname=''
      if [ -L "$fname" ]; then
        target=$(command ls -l "$fname")
        target=${target#* -> }
        continue
      fi
      break
  done
  targetDir=$(command pwd -P)
  if [ "$fname" = '.' ]; then
    command printf '%s\n' "${targetDir%/}"
  elif  [ "$fname" = '..' ]; then
    command printf '%s\n' "$(command dirname -- "${targetDir}")"
  else
    command printf '%s\n' "${targetDir%/}/$fname"
  fi
)

EXEC=$(rreadlink "$0")
DIR=$(dirname -- "$EXEC")


# ============================================
# Actual script starts here

cd $DIR/..

cp resources/Config.pm.tmpl lib/App/Rakubrew/Config.pm
perl -pi -E 's/<\%distro_format\%>/perl/' lib/App/Rakubrew/Config.pm

cpanm App::ModuleBuildTiny App::FatPacker
mbtiny regenerate
cpanm -n .
fatpack trace script/rakubrew
for X in `ls -1 lib/App/Rakubrew/Shell`; do echo App/Rakubrew/Shell/$X >> fatpacker.trace; done
fatpack packlists-for `cat fatpacker.trace` > packlists
fatpack tree `cat packlists`
fatpack file script/rakubrew > rakubrew
chmod +x rakubrew

# Reset our modified Config.pm again.
git checkout -f lib/App/Rakubrew/Config.pm

