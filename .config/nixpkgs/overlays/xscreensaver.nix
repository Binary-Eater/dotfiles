self: super:
{
  xscreensaver = super.xscreensaver.overrideAttrs (
    _: {
          version = "6.06";
          src = builtins.fetchurl {
            url = "https://www.jwz.org/${super.xscreensaver.pname}/${super.xscreensaver.pname}-${self.xscreensaver.version}.tar.gz";
            sha256 = "19wrfi77mgnl0zifp1lkxnjdd9qcp0hzr4cfpswfavc3bawgld7m";
          };
          buildInputs = super.xscreensaver.buildInputs ++ [ super.pkgs.gtk3 ];
    }
  );
}
