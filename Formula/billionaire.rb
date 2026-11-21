# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/billionaire/cli/scripts/release.sh` on every release:
#
#   1.1.0              ← `version` field of apps/billionaire/cli/package.json
#   c92fa1922b9fb3d33cf3d438f5f07e9a2e3a9a40eea4a22d2d1536018939c927     ← sha256 of billionaire-darwin-arm64.tar.gz
#   92e077df32d4e8ee306726efcbceffc41722a4a01532392c2e22aab657978239       ← sha256 of billionaire-darwin-x64.tar.gz
#   533c910db1513052efb59f4a63322421dd8218ebad7ca9bcc5a5250f405a6369      ← sha256 of billionaire-linux-arm64.tar.gz
#   a7ed04ee704b09dcbaa40b895de6b96c4e3e922a314357f38d108908c8f0f83e        ← sha256 of billionaire-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/billionaire-sh/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Billionaire < Formula
  desc "Agent-friendly command-line interface for the billionaire platform"
  homepage "https://github.com/billionaire-sh/cli"
  version "1.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-arm64.tar.gz"
      sha256 "c92fa1922b9fb3d33cf3d438f5f07e9a2e3a9a40eea4a22d2d1536018939c927"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-x64.tar.gz"
      sha256 "92e077df32d4e8ee306726efcbceffc41722a4a01532392c2e22aab657978239"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-arm64.tar.gz"
      sha256 "533c910db1513052efb59f4a63322421dd8218ebad7ca9bcc5a5250f405a6369"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-x64.tar.gz"
      sha256 "a7ed04ee704b09dcbaa40b895de6b96c4e3e922a314357f38d108908c8f0f83e"
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
