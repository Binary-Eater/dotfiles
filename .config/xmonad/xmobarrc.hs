-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"
-- you can find weather location codes here: http://weather.noaa.gov/index.html

Config { font            = "xft:mononoki"
       , additionalFonts = [ "xft:Font Awesome 6 Free:style=Solid:pixelsize=13"
                           , "xft:Font Awesome 6 Brands:pixelsize=13"
                           ]
       , bgColor         = "#292b2e"
       , fgColor         = "#ff6c6b"
       , position        = Static { xpos = 0
                                  , ypos = 0
                                  , width = 1920
                                  , height = 30
                                  }
       , lowerOnStart    = True
       , hideOnStart     = False
       , allDesktops     = True
       , persistent      = True
       , iconRoot        = "/home/binary-eater/.config/xmonad/xpm/"                                                -- default: "."
       , commands        = [ Run Date "<fn=1>\xf017</fn> %H:%M:%S" "date" 50                                       -- Time
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
                           , Run BatteryP ["BAT0"] [ "-t"
                                                   , "<fn=1><acstatus></fn>  <left>%"
                                                   , "--"
                                                   , "-O"
                                                   , "\xe55b"
                                                   , "-i"
                                                   , "\xe55c"
                                                   , "-o"
                                                   , "\xf241"
                                                   , "-l"
                                                   , "red"
                                                   , "-a"
                                                   , "dunstify -u critical -a 'Xmobar' 'Battery charge is low' 'Please charge the battery or power off the device soon.'"
                                                   ] 20                                                            -- Battery information
                           , Run Com "nixos-version" [] "" 3600                                                    -- Runs a standard shell command 'nixos-version' to get NixOS release version
                           , Run Com "uname" ["-r"] "" 3600                                                        -- Runs a standard shell command 'uname -r' to get kernel version
                           , Run Com "/home/binary-eater/.config/xmonad/trayer-padding-icon.sh" [] "trayerpad" 20  -- Script that dynamically adjusts xmobar padding depending on number of trayer icons
                           , Run StdinReader                                                                       -- Prints out the left side items such as workspaces, layout, etc
                           -- Does not accept dynamic actions
                           -- Use UnsafeStdinReader if dynamic actions are needed
                           ]
       , sepChar         = "%"
       , alignSep        = "}{"
       , template = " <icon=haskell_20.xpm/> <fc=#666666>  |</fc> %StdinReader% }{ <fc=#666666> |</fc> <fc=#b3afc2><fn=2></fn>  %uname% </fc><fc=#666666> |</fc> <fc=#c678dd><fn=1></fn>  NixOS %nixos-version% </fc><fc=#666666> |</fc> <fc=#ecbe7b> %cpu% </fc><fc=#666666> |</fc> <fc=#ff6c6b> %memory% </fc><fc=#666666> |</fc> <fc=#98be65> %battery% </fc><fc=#666666> |</fc> <fc=#46d9ff> %date%  </fc><fc=#666666>|</fc>%trayerpad%"
       }
