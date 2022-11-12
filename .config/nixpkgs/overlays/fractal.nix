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
          version = "5-alpha1";

          src = super.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "GNOME";
            repo = "fractal";
            rev = self.fractal.version;
            sha256 = "gHMfBGrq3HiGeqHx2knuc9LomgIW9QA9fCSCcQncvz0=";
          };

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
            hash = "sha256-ImGnr4Oa3eToTAwDZKoWEFC326LVkwUCJsUPbl/taPo=";
          };
    }
  );
}
