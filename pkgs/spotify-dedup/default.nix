{
  busybox,
  callPackage,
  dockerTools,
  nodejs,
}:
let
  spotify-dedup = callPackage ./spotify-dedup.nix { };
in
dockerTools.buildImage {
  name = "spotify-dedup";
  tag = "latest";

  copyToRoot = [
    busybox
    dockerTools.binSh
    dockerTools.caCertificates
    nodejs
  ];

  config = {
    Cmd = [
      "/bin/node"
      "${spotify-dedup}/server.js"
    ];
    ExposedPorts = {
      "3000/tcp" = { };
    };
  };
}
