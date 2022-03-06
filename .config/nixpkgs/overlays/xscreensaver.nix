self: super:
{
  xscreensaver = super.xscreensaver.overrideAttrs (
    _: {
          src = builtins.fetchurl {
            url = "https://www.jwz.org/${super.xscreensaver.pname}/${super.xscreensaver.pname}-5.45.tar.gz";
            sha256 = "03fmyjlwjinzv7mih6n07glmys8s877snd8zijk2c0ds6rkxy5kh";
          };
          buildInputs = super.xscreensaver.buildInputs ++ [ super.pkgs.bc ];
    }
  );
}
