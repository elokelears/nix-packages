{
  stdenv,
  fetchurl,
  electron,
  lib,
  makeWrapper,
  autoPatchelfHook,
  libxshmfence,
  ...
} @ args:
stdenv.mkDerivation (rec {
    pname = "bilibili";
    version = "1.2.1-1";
    src = fetchurl {
      url = "https://github.com/msojocs/bilibili-linux/releases/download/v1.2.1-1/io.github.msojocs.bilibili_1.2.1-1_amd64.deb";
      sha256 = "sha256-t/igezm0ipkOkKION8qTYGK9f6qI3c4iPuS/wWrMywQ=";
    };

    nativeBuildInputs = [makeWrapper autoPatchelfHook];
    buildInputs = [libxshmfence];

    unpackPhase = ''
      ar x ${src}
      tar xf data.tar.xz
    '';

    installPhase = ''
      mkdir -p $out/{bin,opt}
      cp -r usr/share $out/share
      cp -r opt/apps/io.github.msojocs.bilibili/files/bin/app.asar $out/opt

      sed -i "s|/opt/apps/.*/files/bin|$out/bin|g" $out/share/applications/*.desktop

      makeWrapper ${electron}/bin/electron $out/bin/bilibili \
        --argv0 "bilibili" \
        --add-flags "$out/opt/app.asar"
    '';
  }
  // args)
