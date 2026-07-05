#!/usr/bin/env bash
set -euo pipefail
have(){ command -v "$1" >/dev/null 2>&1; }
green(){ printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[1;33m%s\033[0m\n' "$*"; }
red(){ printf '\033[1;31m%s\033[0m\n' "$*"; }
blue(){ printf '\033[1;34m%s\033[0m\n' "$*"; }
