{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spotify-dedup";
  version = "0-unstable-2026-01-07";

  src = fetchFromGitHub {
    owner = "JMPerez";
    repo = "spotify-dedup";
    rev = "d1953e3a49bba8215f2360efe6857646e599906f";
    hash = "sha256-T1Lpt3Yf8pimFrfb4XBZxVSTACmCDXP8ezEVzQgbEEE=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_9
    pnpmConfigHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-YZnqqhq/YjpcKK1vjwIx6bTZbIzIBw/uMANjz6eZwbA=";
  };

  buildPhase = ''
    runHook preBuild
    cat > next.config.ts << EOL
    import type { NextConfig } from "next";

    const nextConfig: NextConfig = {
      output: "standalone",
      env: {
        NEXT_PUBLIC_REDIRECT_URI: "http://127.0.0.1:3000/callback",
        NEXT_PUBLIC_SPOTIFY_CLIENT_ID: "",
        SPOTIFY_CLIENT_SECRET: "",
      },
    };

    export default nextConfig;
    EOL
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    pnpm build
    mkdir -p $out
    mv -T .next/standalone $out
    mv .next/static $out/.next
    mv public $out
    runHook postInstall
  '';

  meta = {
    description = "Remove duplicates from your Spotify Playlists";
    homepage = "https://github.com/JMPerez/spotify-dedup";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
