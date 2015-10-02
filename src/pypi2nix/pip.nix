{ path
, cache ? "$out/cache"
, extraBuildInputs ? []
}:

let

  pkgs = import <nixpkgs> {};
  pypi2nix_bootstrap = import ./bootstrap.nix {
    inherit (pkgs) stdenv fetchurl unzip which makeWrapper python;
  };

in pkgs.stdenv.mkDerivation rec {
  name = "pypi2nix-py2txt";
  __noChroot = true;

  buildInputs = [
    pypi2nix_bootstrap pkgs.unzip
  ] ++ (map (name: builtins.getAttr name pkgs) extraBuildInputs);

  buildCommand = ''
    unset http_proxy
    unset https_proxy
    unset ftp_proxy

    mkdir -p $out/cache $out/wheelhouse

    export PYTHONPATH=${pypi2nix_bootstrap}/base

    PYTHONPATH=${pypi2nix_bootstrap}/extra:$PYTHONPATH pip wheel ${path} --wheel-dir ${cache} --find-links ${cache}
    PYTHONPATH=$out/wheelhouse:$PYTHONPATH pip freeze > $out/requirements.txt

    cd $out/wheelhouse
    for file in ${cache}/*; do
      unzip -qo $file
    done
  '';
}
