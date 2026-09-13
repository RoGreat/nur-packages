{
  fetchFromGitHub,
  lib,
  libiconv,
  onnxruntime,
  python3Packages,
  rustPlatform,
  stdenv,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "headroom";
  version = "0.37.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "headroomlabs-ai";
    repo = "headroom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-89Tkzx56QIZWfNWLaiPdMynZGOLPr5EAP5RnLSgvBsA=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-iEvap6uLsAqCSv+l/S7K7osxL+yV7Y8pE6Dhaqt2AIA=";
  };

  # https://github.com/NixOS/nixpkgs/pull/529964
  postPatch = ''
    substituteInPlace headroom/cli/wrap.py \
      --replace-fail \
        '[sys.executable, "-m", "headroom.cli", "proxy",' \
        '["headroom", "proxy",'
  '';

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = [ onnxruntime ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  env = {
    ORT_DYLIB_PATH = "${onnxruntime}/lib/libonnxruntime${stdenv.hostPlatform.extensions.sharedLibrary}";
  };

  dependencies =
    with python3Packages;
    [
      tiktoken
      pydantic
      litellm
      click
      rich
      opentelemetry-api
      ast-grep-cli
      pyyaml
      tomlkit
      # [mcp]
      mcp
      httpx
      starlette
      uvicorn
    ]
    ++ lib.optionals (lib.versionOlder "3.11" finalAttrs.pythonVersion or "3.11") [ tomli ];

  pythonRelaxDeps = [ "litellm" ];

  nativeCheckInputs = with python3Packages; [
    # pytest
    pytestCheckHook
    pytest-cov
    pytest-asyncio
    # tests
    fastapi
    numpy
    opentelemetry-sdk
    respx
    websockets
  ];

  pythonImportsCheck = [
    "headroom"
  ];

  __structuredAttrs = true;

  meta = {
    description = "Context compression layer for LLM applications — 60–95% fewer tokens";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    changelog = "https://github.com/headroomlabs-ai/headroom/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "headroom";
    platforms = lib.platforms.unix;
  };
})
