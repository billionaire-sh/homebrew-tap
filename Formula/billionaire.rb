# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/billionaire/cli/scripts/release.sh` on every release:
#
#   0.3.0              ← `version` field of apps/billionaire/cli/package.json
#   9c5b211922b93ac19fe694e9a488b8829a72ba8d16d95afde111092338168050     ← sha256 of billionaire-darwin-arm64.tar.gz
#   6afae504aee7c9b6574558e972213b1501d96abc7c51159b9a19bd6f8c02cf55       ← sha256 of billionaire-darwin-x64.tar.gz
#   95f3dd288dde854a69e1213887162911a5913fe847926efb14987a020272b1c3      ← sha256 of billionaire-linux-arm64.tar.gz
#   2e5e7f012d2aa43c8300cb1c095bd1a2402ad2fbcc818b8ed810a0c21b4980eb        ← sha256 of billionaire-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/billionaire-sh/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Billionaire < Formula
  desc "Agent-friendly command-line interface for the billionaire platform"
  homepage "https://github.com/billionaire-sh/cli"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-arm64.tar.gz"
      sha256 "9c5b211922b93ac19fe694e9a488b8829a72ba8d16d95afde111092338168050"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-x64.tar.gz"
      sha256 "6afae504aee7c9b6574558e972213b1501d96abc7c51159b9a19bd6f8c02cf55"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-arm64.tar.gz"
      sha256 "95f3dd288dde854a69e1213887162911a5913fe847926efb14987a020272b1c3"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-x64.tar.gz"
      sha256 "2e5e7f012d2aa43c8300cb1c095bd1a2402ad2fbcc818b8ed810a0c21b4980eb"
    end
  end

  def install
    # The Bun-compiled standalone embeds the Bun runtime, which prints
    # `warn: CPU lacks AVX support, strange crashes may occur. Reinstall
    # Bun or use *-baseline build:` to stderr on every invocation when
    # the host CPU lacks AVX. The advice in that warning ("use *-baseline
    # build") is a dead end: the official `bun-darwin-x64-baseline` /
    # `bun-linux-x64-baseline` runtimes ALSO emit the same warning, and
    # `bun build --compile --target=*-baseline` produces a binary that
    # warns identically. Treat the warning as non-actionable Bun noise
    # and filter the two lines (warning + URL) at the wrapper level so
    # `billionaire …` looks like any other CLI.
    #
    # The wrapper preserves stdout, exit code, signal handling, and
    # argv quoting; it only mutates stderr by dropping the two known
    # AVX lines.
    libexec.install "billionaire" => "billionaire-bin"
    (bin/"billionaire").write <<~SH
      #!/bin/bash
      exec "#{libexec}/billionaire-bin" "$@" \\
        2> >(grep -v -E '^warn: CPU lacks AVX support|^  https://github\\.com/oven-sh/bun/releases/download/.*-baseline\\.zip' >&2)
    SH
    chmod 0755, bin/"billionaire"
  end

  test do
    # The version check also exercises the wrapper — if the wrapper is
    # broken, this test fails before we ship the formula.
    assert_match version.to_s, shell_output("#{bin}/billionaire --version")
  end
end
