{
  stdenv,
  fetchurl,
  electron,
  lib,
  makeWrapper,
  ...
} @ args:
################################################################################
# Mostly based on bilibili-bin package from AUR:
# https://aur.archlinux.org/packages/bilibili-bin
################################################################################
stdenv.mkDerivation rec {
  pname = "bilibili";
  version = "1.2.1-1";
  src = fetchurl {
    url = "https://github.com/msojocs/bilibili-linux/releases/download/v1.2.1-1/io.github.msojocs.bilibili_1.2.1-1_amd64.deb";
    sha256 = "sha256-t/igezm0ipkOkKION8qTYGK9f6qI3c4iPuS/wWrMywQ=";
  };

  # 解压 DEB 包
  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  # makeWrapper 可以自动生成一个调用其它命令的命令（也就是 wrapper），并且可以在原命令上修改参数、环境变量等
  buildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin

    # 替换菜单项目（desktop 文件）中的路径
    cp -r usr/share $out/share
    sed -i "s|Exec=.*|Exec=$out/bin/bilibili|" $out/share/applications/*.desktop

    # 复制出客户端的 Javascript 部分，其它的不要了
    cp -r opt/apps/io.github.msojocs.bilibili/files/bin/app $out/opt

    # 生成 bilibili 命令，运行这个命令时会调用 electron 加载客户端的 Javascript 包（$out/opt/app.asar）
    makeWrapper ${electron}/bin/electron $out/bin/bilibili \
      --argv0 "bilibili" \
      --add-flags "$out/opt/app.asar"
  '';
}
