{ stdenv
, lib
, gitignoreSource
, buildInputs
, nativeBuildInputs
, clang_16
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: let
  serenity = fetchFromGitHub {
    owner = "serenityos";
    repo = "serenity";
    rev = "05e78dabdbceea46bae7dca52b63dc0a115e7b52"; # latest at the time
    hash = "sha256-ymXQ68Uib1xP4eGPuxm3vRgAIhrVK4rmHdGLfuvsOJU=";
  };
in {
  inherit buildInputs nativeBuildInputs;
  name = "jakt-unwrapped";
  src = gitignoreSource ./.;
  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=${clang_16}/bin/clang++"
    "-DSERENITY_SOURCE_DIR=${serenity}"
    "-DCMAKE_INSTALL_BINDIR=bin"
  ];
})
