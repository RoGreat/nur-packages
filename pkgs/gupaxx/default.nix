{
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitHub,
  lib,
  libGL,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
  xorg,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupaxx";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "Cyrix126";
    repo = "gupaxx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+EHYIsfVmzCuTcb37BCU+RW1mqK7dNUA1fAxgZEOdto=";
  };

  cargoHash = "sha256-u7yBz0ApwHMopvw5BQ7r+v9b9l0FsQoyOjJZ94msxxA=";

  checkFlags = [
    # Test requires filesystem write outside of sandbox.
    "--skip disk::test::create_and_serde_gupax_p2pool_api"
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    openssl
    # https://github.com/NixOS/nixpkgs/issues/225963
    stdenv.cc.cc.libgcc or null
  ];

  runtimeDependencies = [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  installPhase = ''
    runHook preInstall
    install -m 444 -D "assets/images/icons/icon.png" "$out/share/icons/hicolor/256x256/apps/gupax.png"
    install -m 444 -D "assets/images/icons/icon@2x.png" "$out/share/icons/hicolor/1024x1024/apps/gupax.png"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gupaxx";
      desktopName = "Gupaxx";
      icon = "gupaxx";
      exec = finalAttrs.meta.mainProgram;
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Utility"
      ];
    })
  ];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

  # Use rust nightly features
  RUSTC_BOOTSTRAP = 1;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of Gupax integrating the XMRvsBeast Raffle";
    homepage = "https://github.com/Cyrix126/gupaxx";
    changelog = "https://github.com/Cyrix126/gupaxx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupaxx";
    platforms = lib.platforms.linux;
  };
})
