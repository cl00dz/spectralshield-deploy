class Spectrashield < Formula
  desc "Self-hosted audio watermarking app"
  homepage "https://github.com/cl00dz/spectralshield-deploy"
  url "https://github.com/cl00dz/spectralshield-deploy/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "<FILL_TARBALL_SHA256>"
  license "MIT"

  depends_on "docker"

  def install
    bin.install "deploy.sh" => "spectrashield"
  end

  test do
    system "#{bin}/spectrashield", "--help"
  end
end
