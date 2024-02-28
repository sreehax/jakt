{ lib
, stdenv
, makeWrapper
, buildInputs
, nativeBuildInputs
, gitignoreSource
, clang_16
, callPackage
, symlinkJoin
}: let
  jakt-unwrapped = callPackage ./jakt-unwrapped.nix {
    inherit buildInputs nativeBuildInputs gitignoreSource;
  };
in

symlinkJoin {
  name = "jakt";
  paths = [ jakt-unwrapped ];
  nativeBuildInputs = [
    makeWrapper
    jakt-unwrapped
  ];
  postBuild = ''
    wrapProgram $out/bin/jakt_stage0 \
      --prefix PATH : ${clang_16}/bin
    wrapProgram $out/bin/jakt_stage1 \
      --prefix PATH : ${clang_16}/bin
  '';
  passthru.unwrapped = jakt-unwrapped;
}
