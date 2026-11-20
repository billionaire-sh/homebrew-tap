# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/billionaire/cli/scripts/release.sh` on every release:
#
#   0.4.0              ← `version` field of apps/billionaire/cli/package.json
#   b81dd28219e5ed3ec5fa84f9b04d9cb72433a57b7a1bbbf5d6dac22d4c0f09ac     ← sha256 of billionaire-darwin-arm64.tar.gz
#   f0b97ac4927ca44ce8e40454bb264c0861ee87b7cb2c1608e7f82bf9e7b1c22f       ← sha256 of billionaire-darwin-x64.tar.gz
#   1bba32efaf7360f49652c5e50dc6f9844423ca46b031afdbcdb70ce847033b74      ← sha256 of billionaire-linux-arm64.tar.gz
#   8dcffd50901fb53c2d431ea2069f7391b239d3a9789d1c008d7dfdbe7d1805bb        ← sha256 of billionaire-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/billionaire-sh/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Billionaire < Formula
  desc "Agent-friendly command-line interface for the billionaire platform"
  homepage "https://github.com/billionaire-sh/cli"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-arm64.tar.gz"
      sha256 "b81dd28219e5ed3ec5fa84f9b04d9cb72433a57b7a1bbbf5d6dac22d4c0f09ac"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-x64.tar.gz"
      sha256 "f0b97ac4927ca44ce8e40454bb264c0861ee87b7cb2c1608e7f82bf9e7b1c22f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-arm64.tar.gz"
      sha256 "1bba32efaf7360f49652c5e50dc6f9844423ca46b031afdbcdb70ce847033b74"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-x64.tar.gz"
      sha256 "8dcffd50901fb53c2d431ea2069f7391b239d3a9789d1c008d7dfdbe7d1805bb"
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
