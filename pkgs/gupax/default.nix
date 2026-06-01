{
  copyDesktopItems,
  cuprate,
  fetchFromGitHub,
  lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupax";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "hinto-janai";
    repo = "gupax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BBFovEZwjZNcC8eEnp3IgQf70O1QCJ+tdwxHk+vUp1E=";
  };

  cargoHash = "sha256-7Kew11N/rakHLhKBu+BUM3f4AP9xDZl1xARpbyqHCFY=";

  checkFlags = [
    # Test requires filesystem write outside of sandbox.
    "--skip disk::test::create_and_serde_gupax_p2pool_api"
    # Tests require access to CA certificates.
    "--skip disk::tests::test::create_and_serde_gupax_p2pool_api"
    "--skip helper::tests::test::public_api_deserialize"
    "--skip helper::xvb::algorithm::test::test_manual_p2pool_mode"
    "--skip helper::xvb::algorithm::test::test_manual_xvb_mode"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    cuprate
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    openssl
    wayland
  ];

  postInstall = ''
    install -D assets/images/icons/icon.png $out/share/icons/hicolor/256x256/apps/gupax.png
    install -D assets/images/icons/icon@2x.png $out/share/icons/hicolor/1024x1024/apps/gupax.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gupax";
      desktopName = "Gupax";
      icon = "gupax";
      exec = "gupax";
      comment = "P2Pool and XMRig";
      categories = [ "Utility" ];
    })
  ];

  doCheck = false;

  env = {
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    # Use Rust nightly.
    RUSTC_BOOTSTRAP = 1;
  };

  meta = {
    description = "GUI Uniting P2Pool And XMRig";
    homepage = "https://gupax.io";
    changelog = "https://github.com/hinto-janai/gupax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupax";
    platforms = lib.platforms.linux;
  };
})
