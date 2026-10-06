class Pages < Formula
  desc "Render Apple Pages documents in the terminal"
  homepage "https://github.com/crsves/pages"
  url "https://github.com/crsves/pages/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "eafcc18e8e7122a0a776d8e65fc7f9ee50d1866b7a1364a182658412e8a3c03d"
  license "MIT"
  head "https://github.com/crsves/pages.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"pages", "--generate-completions")
    (man1/"pages.1").write Utils.safe_popen_read(bin/"pages", "--generate-man")
  end

  test do
    resource "homebrew-fixture" do
      url "https://raw.githubusercontent.com/crsves/pages/v0.1.1/tests/fixtures/fixture.pages"
      sha256 "d03a83afe3dc67122dd0bb15e838080c092c428a4379bd87527e832fcdcc5c4b"
    end

    resource("homebrew-fixture").stage testpath
    output = shell_output("#{bin}/pages --color never -w 70 #{testpath}/fixture.pages")
    assert_match "The Fixture Essay", output
    assert_match "│ Ada   │ Analyst │ 1843 │", output

    (testpath/"not.pages").write "plain text"
    assert_match "not a Pages document", shell_output("#{bin}/pages #{testpath}/not.pages 2>&1", 1)
  end
end
