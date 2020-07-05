let
  nixpkgs = import <nixpkgs> {
    config = {
      packageOverrides = super: {
        haskellPackages = super.haskellPackages.override {
          overrides = self: super: {
            aufgaben = self.callCabal2nix "aufgaben" ./aufgaben {};
          };
        };
      };
    };
  };

  tex = nixpkgs.texlive.combine {
    inherit (nixpkgs.texlive) scheme-small amsmath;
  };

  gen = nixpkgs.writeScript "gen.sh" ''
  #!${nixpkgs.bash}/bin/bash
  ${nixpkgs.haskellPackages.aufgaben}/bin/aufgaben 45 > aufgaben.tex
  ${tex}/bin/pdflatex aufgaben.tex
  '';
in
  nixpkgs.mkShell {
    buildInputs = [
      gen
    ];
  }
