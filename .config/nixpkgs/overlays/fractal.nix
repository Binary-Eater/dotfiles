self: super:
let
  unstable = import <nixos-unstable> {};
  rustPlatform = unstable.rustPlatform;
  libadwaita = unstable.libadwaita;
  meson = unstable.meson;
in
{
  fractal = super.fractal.overrideAttrs (
    _: rec {
          version = "5-alpha1-rc.1";

          src = ~/Documents/fractal;

          LIBCLANG_PATH = "${super.libclang.lib}/lib";

          nativeBuildInputs = super.lib.remove super.meson
            (super.lib.remove super.rustPlatform.rust.rustc
            (super.lib.remove super.rustPlatform.cargoSetupHook
            (super.lib.remove super.rustPlatform.rust.cargo super.fractal.nativeBuildInputs)))
            ++ [
              rustPlatform.rust.cargo
              rustPlatform.cargoSetupHook
              rustPlatform.rust.rustc
              meson
              super.cmake
              super.desktop-file-utils
            ];
          buildInputs = super.lib.remove super.gtksourceview4
            (super.lib.remove super.gtk3 super.fractal.buildInputs)
            ++ [
                 super.gtk4
                 super.gtksourceview5
                 libadwaita
                 super.libsecret
                 super.pipewire
                 super.libshumate
                 super.clang
                 super.appstream-glib
               ];

          patches = [];

          postPatch = ''
            chmod +x scripts/checks.sh
            patchShebangs scripts/checks.sh
          '';

          cargoDeps = super.rustPlatform.fetchCargoTarball {
            inherit src;
            name = "${super.fractal.pname}-${self.fractal.version}";
            hash = "sha256-pUZnC0Vc9hWYLCvcakRx6bxJxWdoX1HnbHoAqmjAV90=";
          };
    }
  );
}
