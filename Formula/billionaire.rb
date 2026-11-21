# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/billionaire/cli/scripts/release.sh` on every release:
#
#   1.0.0              ← `version` field of apps/billionaire/cli/package.json
#   59be82dd8a8ddd3d52e37172e9d3b88570ee416b639c84f9f6ba376085a15853     ← sha256 of billionaire-darwin-arm64.tar.gz
#   92aa14b75f334f7f424a67ba5b6ef4628b9f2d05abb584ec6559827c46a02928       ← sha256 of billionaire-darwin-x64.tar.gz
#   3e8287a66292614e6556f550718662da2ba5aa41de64b4ef2dbeae49b08cd13b      ← sha256 of billionaire-linux-arm64.tar.gz
#   0b22d744a04724d7cd98e7fefc4f4a7e884f30f10acc4be48c71de2351f33214        ← sha256 of billionaire-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/billionaire-sh/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Billionaire < Formula
  desc "Agent-friendly command-line interface for the billionaire platform"
  homepage "https://github.com/billionaire-sh/cli"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-arm64.tar.gz"
      sha256 "59be82dd8a8ddd3d52e37172e9d3b88570ee416b639c84f9f6ba376085a15853"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-darwin-x64.tar.gz"
      sha256 "92aa14b75f334f7f424a67ba5b6ef4628b9f2d05abb584ec6559827c46a02928"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-arm64.tar.gz"
      sha256 "3e8287a66292614e6556f550718662da2ba5aa41de64b4ef2dbeae49b08cd13b"
    end
    on_intel do
      url "https://github.com/billionaire-sh/cli/releases/download/v#{version}/billionaire-linux-x64.tar.gz"
      sha256 "0b22d744a04724d7cd98e7fefc4f4a7e884f30f10acc4be48c71de2351f33214"
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
