-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"
-- you can find weather location codes here: http://weather.noaa.gov/index.html

Config { font            = "xft:mononoki:pixelsize=11:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Font Awesome 5 Free:style=Solid:pixelsize=13"
                           , "xft:Font Awesome 5 Brands:pixelsize=13"
                           ]
       , bgColor         = "#292b2e"
       , fgColor         = "#ff6c6b"
       , position        = Static { xpos = 0
                                  , ypos = 0
                                  , width = 3440
                                  , height = 30
                                  }
       , lowerOnStart    = True
       , hideOnStart     = False
       , allDesktops     = True
       , persistent      = True
       , iconRoot        = "/home/binary-eater/.config/xmonad/xpm/" -- default: "."
       , commands        = [ Run Date "<fn=1>\xf133</fn> %b %d %Y - (%H:%M:%S)" "date" 50                          -- Time and date
                           , Run Network "enp42s0" [ "-t"
                                                   , "<fn=1>\xf0aa</fn>  <rx>kb  <fn=1>\xf0ab</fn>  <tx>kb"
                                                   ] 20                                                            -- 2.5Gbps network up and down
                           , Run Network "enp6s0" [ "-t"
                                                  , "<fn=1>\xf0aa</fn>  <rx>kb  <fn=1>\xf0ab</fn>  <tx>kb"
                                                  ] 20                                                             -- 1Gbps network up and down
                           , Run Cpu [ "-t"
                                     , "<fn=1>\xf108</fn>  cpu: (<total>%)"
                                     , "-H"
                                     , "50"
                                     , "--high"
                                     , "red"
                                     ] 20                                                                          -- Cpu usage in percent
                           , Run Memory [ "-t"
                                        , "<fn=1>\xf233</fn>  mem: <used>M (<usedratio>%)"
                                        ] 20                                                                       -- Ram usage value and percent
                           , Run DiskU [ ("/", "<fn=1>\xf0c7</fn>  root: <free> free")
                                       , ("/home", "  home: <free> free")
                                       ] [] 60                                                                     -- Disk space free
                           , Run Com "nixos-version" [] "" 3600                                                    -- Runs a standard shell command 'nixos-version' to get NixOS release version
                           , Run Com "uname" ["-r"] "" 3600                                                        -- Runs a standard shell command 'uname -r' to get kernel version
                           , Run Com "/home/binary-eater/.config/xmonad/trayer-padding-icon.sh" [] "trayerpad" 20  -- Script that dynamically adjusts xmobar padding depending on number of trayer icons
                           , Run StdinReader                                                                       -- Prints out the left side items such as workspaces, layout, etc
                           -- Does not accept dynamic actions
                           -- Use UnsafeStdinReader if dynamic actions are needed
                           ]
       , sepChar         = "%"
       , alignSep        = "}{"
       , template = " <icon=haskell_20.xpm/> <fc=#666666>  |</fc> %StdinReader% }{ <fc=#666666> |</fc> <fc=#b3afc2><fn=2></fn>  %uname% </fc><fc=#666666> |</fc> <fc=#c678dd><fn=1></fn>  NixOS %nixos-version% </fc><fc=#666666> |</fc> <fc=#ecbe7b> %cpu% </fc><fc=#666666> |</fc> <fc=#ff6c6b> %memory% </fc><fc=#666666> |</fc> <fc=#51afef> %disku% </fc><fc=#666666> |</fc> <fc=#98be65> 2.5Gbps [ %enp42s0% ]  1Gbps [ %enp6s0% ] </fc><fc=#666666> |</fc>  <fc=#46d9ff> %date%  </fc><fc=#666666>|</fc>%trayerpad%"
       }
