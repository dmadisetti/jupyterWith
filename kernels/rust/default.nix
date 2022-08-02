{
  self,
  pkgs,
  evcxr ? pkgs.evcxr,
  # TODO: extra packages
}: {
  name ? "rust",
  displayName ? "Rust", # TODO: add Rust version
  language ? "rust",
  argv ? null,
  codemirrorMode ? "rust",
  logo64 ? ./logo64.png,
  logo32 ? ./logo32.png,
  runtimePackages ? with pkgs; [cargo gcc binutils-unwrapped],
  extraRuntimePackages ? [],
}: let
  allRuntimePackages = runtimePackages ++ extraRuntimePackages;

  env = evcxr;
  wrappedEnv =
    pkgs.runCommand "wrapper-${env.name}"
    {nativeBuildInputs = [pkgs.makeWrapper];}
    ''
      mkdir -p $out/bin
      for i in ${env}/bin/*; do
        filename=$(basename $i)
        ln -s ${env}/bin/$filename $out/bin/$filename
        wrapProgram $out/bin/$filename \
          --set PATH "${pkgs.lib.makeSearchPath "bin" allRuntimePackages}" \
          --set RUST_SRC_PATH "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"
      done
    '';

  argv_ =
    if argv == null
    then [
      "${wrappedEnv}/bin/evcxr_jupyter"
      "--control_file"
      "{connection_file}"
    ]
    else argv;
in {
  argv = argv_;
  inherit
    name
    displayName
    language
    codemirrorMode
    logo64
    ;
}
