{- |
Module      :  xmonad-binary-eater
Description :  Binary-Eater XMonad configuration
Copyright   :  (c) Binary-Eater
License     :  GPLv3

Maintainer  :  Rahul Rameshbabu <sergeantsagara@protonmail.com>
Stability   :  unstable | experimental | provisional | stable | frozen
Portability :  portable

Reference   :  http://www.gitlab.com/dwt1/
XMonad configuration based on dwt1's work
Uses hybrid bindings of vim and emacs while trying
to remain faithful to the original XMonad bindings
Oriented towards a "mouse-less" experience
-}

--------------------------
-- Imports
--------------------------
    -- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import System.FilePath.Posix ((</>))
import System.Directory (getHomeDirectory)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (copyToAll, kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Tuple.Extra as TE
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isDialog, isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WallpaperSetter
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier (magnifier)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.ShowWName
import XMonad.Layout.Spacing
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)

    -- Utilities
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

--------------------------
-- User Variables
--------------------------
myFont :: String
myFont = "xft:mononoki:bold:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod1Mask -- Sets modkey to alt key

myTerminal :: String
myTerminal = "urxvt" -- Sets default terminal to urxvt

myBrowser :: String
myBrowser = "qutebrowser" -- Set qutebrowser as browser for tree select
-- TODO Get GNU IceCat installed on NixOS
-- myBrowser = "icecat" -- Sets GNU IceCat as browser for tree select

myBrowserHomepage :: String
myBrowserHomepage = "qutebrowser quickstart - qutebrowser"

myEditor :: String
myEditor = "emacsclient -c -a emacs" -- Sets emacs as editor for tree select
-- myEditor = myTerminal ++ " -e emacsclient -nw -a \"emacs -nw\"" -- Sets emacs in terminal as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 2 -- Sets border width for windows

myNormColor :: String
myNormColor = "#292d3e" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#5e5086" -- Border color of focused windows
-- Focus color values experimented with
-- "#c678dd"
-- "#bbc5ff"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace. W.current . windowset

-- The lists below are actually 3-tuples for use with gridSelect and treeSelect.
-- TreeSelect uses all three values in the 3-tuples but GridSelect only needs first
-- two values in each list (see myAppGrid, myBookmarkGrid and myConfigGrid below).
myApplications :: [(String, String, String)]
myApplications = [ ("Emacs", "emacs", "Much more than a text editor")
                 , ("Qutebrowser", myBrowser, "A keyboard-focused browser with minimal GUI")
--               TODO Get GNU IceCat installed on NixOS
--               , ("GNU IceCat", "icecat", "GNU IceCat is the GNU version of the Firefox browser")
                 , ("Gimp", "gimp", "Open source alternative to Photoshop")
                 , ("URXVT", "urxvt", "Our extended virtual terminal")
                 ]

myBookmarks :: [(String, String, String)]
myBookmarks = [ ("GNU", myBrowser ++ " https://www.gnu.org", "Official website for GNU's Not Unix")
              , ("Haskell", myBrowser ++ " https://wiki.haskell.org/Haskell", "Haskell Wiki")
              , ("Spacemacs", myBrowser ++ " https://develop.spacemacs.org/doc/DOCUMENTATION.html", "Spacemacs Documentation")
              ]

myConfigs :: [(String, String, String)]
myConfigs = [ ("spacemacs config.el", myEditor ++ " $HOME/.spacemacs", "spacemacs config")
            , ("spacemacs init.el", myEditor ++ " $HOME/.emacs.d/init.el", "spacemacs init")
            , ("xmonad.hs", myEditor ++ " $HOME/.xmonad/xmonad.hs", "xmonad config")
            , ("zshrc", myEditor ++ " $HOME/.zshrc", "rc for the z shell")
            , ("zprofile", myEditor ++ " $HOME/.zprofile", "profile for the z shell")
            ]

--------------------------
-- Autostart
--------------------------
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "xscreensaver &"
    spawnOnce "$HOME/.config/xmonad/helpers/xscreensaver_watcher &"
--  Using XMonad.Hooks.Wallpaper.Setter instead
--  spawnOnce "feh --bg-fill $HOME/Pictures/Wallpapers/wallpaper.jpg &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce $ "trayer --edge top --align right --widthtype request --padding 6 --iconspacing 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x" ++ drop 1 myNormColor ++ " --height 30 &"
    spawnOnce "protonmail-bridge --noninteractive &"
    spawnOnce "emacs --daemon &"
--  Only need if working with any ancient version of the Java Runtime
--  setWMName "LG3D" -- https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Hooks-SetWMName.html

--------------------------
-- Grid Select
--------------------------
myGridColorizer :: Window -> Bool -> X (String, String)
myGridColorizer = colorRangeFromClassName
                  (0x29,0x2d,0x3e) -- lowest inactive bg
                  (0x29,0x2d,0x3e) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x29,0x2d,0x3e) -- active fg

-- gridSelect menu layout
myGridConfig :: p -> GSConfig Window
myGridConfig colorizer = (buildDefaultGSConfig myGridColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

-- Let's take myApplications, myBookmarks and myConfigs and take only
-- the first two values from those 3-tuples (for GridSelect).
myAppGrid :: [(String, String)]
myAppGrid = [ (a,b) | (a,b,c) <- xs]
  where xs = myApplications

myBookmarkGrid :: [(String, String)]
myBookmarkGrid = [ (a,b) | (a,b,c) <- xs]
  where xs = myBookmarks

myConfigGrid :: [(String, String)]
myConfigGrid = [ (a,b) | (a,b,c) <- xs]
  where xs = myConfigs

--------------------------
-- Tree Select
--------------------------
treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "applications" "a list of commonly used programs" (return ()))
     [Node (TS.TSNode (TE.fst3 $ myApplications !! n)
                      (TE.thd3 $ myApplications !! n)
                      (spawn $ TE.snd3 $ myApplications !! n)
           ) [] | n <- [0..(length myApplications - 1)]
     ]
   , Node (TS.TSNode "bookmarks" "a list of web bookmarks" (return ()))
     [Node (TS.TSNode(TE.fst3 $ myBookmarks !! n)
                     (TE.thd3 $ myBookmarks !! n)
                     (spawn $ TE.snd3 $ myBookmarks !! n)
           ) [] | n <- [0..(length myBookmarks - 1)]
     ]
   , Node (TS.TSNode "config files" "a list of important config files" (return ()))
     [Node (TS.TSNode (TE.fst3 $ myConfigs !! n)
                      (TE.thd3 $ myConfigs !! n)
                      (spawn $ TE.snd3 $ myConfigs !! n)
           ) [] | n <- [0..(length myConfigs - 1)]
     ]
   ]

-- Configuration options for treeSelect
tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd292d3e
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff202331)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff292d3e)
                              , TS.ts_highlight    = (0xffffffff, 0xff755999)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = TS.defaultNavigation
                              }

--------------------------
-- Xprompt Settings
--------------------------
dtXPConfig :: XPConfig
dtXPConfig = def
      { font                = myFont
      , bgColor             = "#292d3e"
      , fgColor             = "#d0d0d0"
      , bgHLight            = "#c792ea"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , promptKeymap        = dtXPKeymap
      , position            = Top
--    , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
      , showCompletionOnTab = False
      -- , searchPredicate     = isPrefixOf
      , searchPredicate     = fuzzyMatch
      , alwaysHighlight     = True
      , maxComplRows        = Nothing
      }

-- The same config above minus the autocomplete feature which is annoying
-- on certain Xprompts, like the search engine prompts.
dtXPConfig' :: XPConfig
dtXPConfig' = dtXPConfig
      { autoComplete        = Nothing
      }

-- A list of all of the standard Xmonad prompts and a key press assigned to them.
-- These are used in conjunction with keybinding I set later in the config.
promptList :: [(String, XPConfig -> X ())]
promptList = [ ("m", manPrompt)          -- manpages prompt
             , ("p", passPrompt)         -- get passwords (requires 'pass')
             , ("g", passGeneratePrompt) -- generate passwords (requires 'pass')
             , ("r", passRemovePrompt)   -- remove passwords (requires 'pass')
             , ("s", sshPrompt)          -- ssh prompt
             , ("x", xmonadPrompt)       -- xmonad prompt
             ]

-- Same as the above list except this is for my custom prompts.
promptList' :: [(String, XPConfig -> String -> X (), String)]
promptList' = []

--------------------------
-- Custom Prompts
--------------------------
-- calcPrompt requires a cli calculator called qalculate-gtk.
-- You could use this as a template for other custom prompts that
-- use command line programs that return a single line of output.
{-
calcPrompt :: XPConfig -> String -> X ()
calcPrompt c ans =
    inputPrompt c (trim ans) ?+ \input ->
        liftIO(runProcessWithInput "qalc" [input] "") >>= calcPrompt c
    where
        trim  = f . f
            where f = reverse . dropWhile isSpace
-}

------------------------------------------------------------------------
-- Xprompt Keymap (vim-like key bindings for xprompts)
------------------------------------------------------------------------
dtXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
dtXPKeymap = vimLikeXPKeymap' (setBorderColor myNormColor) id id isSpace

--------------------------
-- Search Engines
--------------------------
-- Xmonad has several search engines available to use located in
-- XMonad.Actions.Search. Additionally, you can add other search engines
-- such as those listed below.
archWiki, gnu, haskellWiki, kernelOrgDocs, nixosWiki, nixosPackages, nixosOptions
    :: S.SearchEngine

archWiki      = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
gnu           = S.searchEngine "gnu" "https://www.gnu.org/cgi-bin/estseek.cgi?phrase="
haskellWiki   = S.searchEngine "haskell" "https://wiki.haskell.org/index.php?search="
kernelOrgDocs = S.searchEngine "kernelorg"
                "https://www.kernel.org/doc/html/latest/search.html?q="
nixosWiki     = S.searchEngine "nixoswiki" "https://nixos.wiki/index.php?search="
nixosPackages = S.searchEngine "nixospkgs"
                "https://search.nixos.org/packages?query="
nixosOptions  = S.searchEngine "nixosopts"
                "https://search.nixos.org/options?query="

-- This is the list of search engines that I want to use. Some are from
-- XMonad.Actions.Search, and some are the ones that I added above.
searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archWiki)
             , ("e", S.hoogle)
             , ("g", gnu)
             , ("h", haskellWiki)
             , ("k", kernelOrgDocs)
             , ("s", S.google)
             , ("o", nixosOptions)
             , ("p", nixosPackages)
             , ("r", S.stackage)
             , ("w", nixosWiki)
             , ("y", S.youtube)
             ]

--------------------------
-- Workspaces
--------------------------
myWorkspaces :: [String]
myWorkspaces = ["dev", "www", "sys", "docs", "chat", "mus", "vid", "games", "gfx"]

--------------------------
-- Managehook
--------------------------
-- Sets some rules for certain programs. Examples include forcing certain
-- programs to always float, or to always appear on a certain workspace.
-- Forcing programs to a certain workspace with a doShift requires xdotool
-- if you are using clickable workspaces. You need the className or title
-- of the program. Use xprop to get this info.

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- TODO change Firefox to Icecat
     -- ref: https://wiki.haskell.org/Xmonad/General_xmonad.hs_config_tips#Managing_Windows_aka_Manage_Hooks
     [ className =? "emacs"    --> doShift "dev"
     , className =? "obs"      --> doShift "gfx"
     , className =? "mpv"      --> doShift "vid"
     , className =? "vlc"      --> doShift "vid"
     , (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> (ask >>= doF . W.sink)
     , (className =? "Gimp" <&&> isDialog) --> doFloat
     , className =? "Gimp"     --> doShift "gfx"
     , (className =? myTerminal <&&> title =? "toxic") --> doShift "chat" -- Shift Toxic window
     , className =? myTerminal --> doShift "dev"
     , (className =? myBrowser <&&> isDialog) --> doFloat -- Float browser dialog
     , (className =? myBrowser <&&> title =? myBrowser) --> doShift "www" -- Shift newly opened Qutebrowser window
     ] <+> namedScratchpadManageHook myScratchPads
  where role = stringProperty "WM_WINDOW_ROLE"

--------------------------
-- Loghook
--------------------------
-- Not using since I don't want to depend on a compositor like xcompmgr
-- ref: https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Hooks-FadeInactive.html
-- Sets opacity for inactive (unfocused) windows. I prefer to not use
-- this feature so I've set opacity to 1.0. If you want opacity, set
-- this to a value of less than 1 (such as 0.9 for 90% opacity).
{-
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0
-}

--------------------------
-- Layouts
--------------------------
-- Makes setting the spacingRaw simpler to write. The spacingRaw
-- module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
tall     = renamed [Replace "tall"]
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ limitWindows 7
           $ mySpacing' 4
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ mySpacing' 4
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabConfig
  where
    myTabConfig = def { fontName            = "xft:Mononoki Nerd Font:regular:pixelsize=11"
                      , activeColor         = myNormColor
                      , inactiveColor       = "#3e445e"
                      , activeBorderColor   = myNormColor
                      , inactiveBorderColor = myNormColor
                      , activeTextColor     = "#ffffff"
                      , inactiveTextColor   = "#d0d0d0"
                      }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Sans:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#000000"
    , swn_color             = "#FFFFFF"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               -- I've commented out the layouts I don't use.
               myDefaultLayout =     tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 -- ||| grid
                                 ||| noBorders tabs
                                 -- ||| spirals
                                 -- ||| threeCol
                                 -- ||| threeRow

--------------------------
-- Scratchpads
--------------------------
-- Allows to have several floating scratchpads running different applications.
-- Import Util.NamedScratchpad.  Bind a key to namedScratchpadSpawnAction.
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm ]
  where
    spawnTerm  = myTerminal ++ " -name scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

--------------------------
-- Keybindings
--------------------------
-- I am using the Xmonad.Util.EZConfig module which allows keybindings
-- to be written in simpler, emacs-like format.
myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
        [ ("M-C-r", safeSpawn "xmonad" ["--recompile"])  -- Recompiles xmonad
        , ("M-C-q", safeSpawn "xmonad" ["--restart"])    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                      -- Quits xmonad

    -- Open my preferred terminal
        , ("M-S-<Return>", safeSpawn myTerminal [])

    -- Run Prompt
        , ("M-C-<Return>", shellPrompt dtXPConfig)   -- Shell Prompt

    -- Windows
        , ("M-S-c", kill1)                           -- Kill the currently focused client
        , ("M-S-a", killAll)                         -- Kill all windows on current workspace

    -- Floating windows
        , ("M-f", sendMessage (T.Toggle "floats"))       -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)        -- Push floating window back to tile
        , ("M-S-t", sinkAll)                             -- Push ALL floating windows to tile

    -- Grid Select
        , ("C-i g", spawnSelected' myAppGrid)                     -- grid select favorite apps
        , ("C-i m", spawnSelected' myBookmarkGrid)                -- grid select some bookmarks
        , ("C-i c", spawnSelected' myConfigGrid)                  -- grid select useful config files
        , ("C-i t", goToSelected $ myGridConfig myGridColorizer)  -- goto selected window
        , ("C-i b", bringSelected $ myGridConfig myGridColorizer) -- bring selected window

    -- Tree Select
        -- tree select actions menu
        , ("C-t a", treeselectAction tsDefaultConfig)

    -- Windows navigation
        , ("M-m", windows W.focusMaster)       -- Move focus to the master window
        , ("M-j", windows W.focusDown)         -- Move focus to the next window
        , ("M-k", windows W.focusUp)           -- Move focus to the prev window
        , ("M-<Return>", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)        -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)          -- Swap focused window with prev window
        , ("M-<Backspace>", promote)           -- Moves focused window to master, others maintain order
        , ("M4-S-<Tab>", rotSlavesDown)        -- Rotate all windows except master and keep focus in place
        , ("M4-C-<Tab>", rotAllDown)           -- Rotate all the windows in the current stack
        , ("M-S-s", windows copyToAll)
        , ("M-C-s", killAllOtherCopies)

    -- Layouts
        , ("M-<Space>", sendMessage NextLayout)                                 -- Switch to next layout
        , ("M-S-<Space>", sendMessage FirstLayout)                              -- Switch to first layout
        , ("M-C-M4-j", sendMessage Arrange)
        , ("M-C-M4-k", sendMessage DeArrange)
        , ("M-C-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-v", sendMessage ToggleStruts)                                   -- Toggles struts
        , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)                          -- Toggles noborder
        , ("M-,", sendMessage (IncMasterN 1))                                   -- Increase number of clients in master pane
        , ("M-.", sendMessage (IncMasterN (-1)))                                -- Decrease number of clients in master pane
        , ("M-S-,", increaseLimit)                                              -- Increase number of windows
        , ("M-S-.", decreaseLimit)                                              -- Decrease number of windows
        , ("M-h", sendMessage Shrink)                                           -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                                           -- Expand horiz window width
        , ("M-C-j", sendMessage MirrorShrink)                                   -- Shrink vert window width
        , ("M-C-k", sendMessage MirrorExpand)                                   -- Expand vert window width

    -- Workspaces
        , ("M-e", nextScreen)                                  -- Switch focus to next monitor
        , ("M-w", prevScreen)                                  -- Switch focus to prev monitor
        , ("M-S-e", shiftNextScreen)                           -- Shift window to next monitor
        , ("M-S-w", shiftPrevScreen)                           -- Shift window to prev monitor
        , ("M-C-e", shiftNextScreen >> nextScreen)             -- Shift window and move to next monitor
        , ("M-C-w", shiftPrevScreen >> prevScreen)             -- Shift window and move to prev monitor
        , ("M-S-p", shiftTo Next nonNSP >> moveTo Next nonNSP) -- Shifts focused window to next ws
        , ("M-S-o", shiftTo Prev nonNSP >> moveTo Prev nonNSP) -- Shifts focused window to prev ws

    -- Scratchpads
        , ("M-C-t", namedScratchpadAction myScratchPads "terminal")

    -- Lock screen
        , ("M-C-l", safeSpawn "xscreensaver-command" ["-lock"])

    -- Emacs (CTRL-e followed by a key)
        , ("C-e e", safeSpawn "emacsclient" ["-c", "-a", ""])                                -- start emacs
        , ("C-e b", safeSpawn "emacsclient" ["-c", "-a", "", "--eval", "(ibuffer)"])         -- list emacs buffers
        , ("C-e d", safeSpawn "emacsclient" ["-c", "-a", "", "--eval", "(dired nil)"])       -- dired emacs file manager
        , ("C-e s", safeSpawn "emacsclient" ["-c", "-a", "", "--eval", "(eshell)"])          -- eshell within emacs
        , ("C-e t", safeSpawn "emacsclient" ["-c", "-a", "", "--eval", "(+vterm/here nil)"]) -- vterm within emacs

    -- Multimedia Keys
        -- TODO figure out a default flow for playing music
        -- , ("<XF86AudioPlay>", spawn "cmus toggle")
        -- , ("<XF86AudioPrev>", spawn "cmus prev")
        -- , ("<XF86AudioNext>", spawn "cmus next")
        , ("<XF86AudioMute>", safeSpawn "amixer" ["set", "Master", "toggle"])
        , ("<XF86HomePage>", safeSpawn myBrowser [])
        , ("<XF86Search>", safeSpawn myBrowser ["https://www.google.com/"])
        , ("<XF86Eject>", safeSpawn "eject" ["-T"])
        -- Breaking support for shells like tcsh by using "$(...)" syntax
        -- for command substitution in place of "`...`"
        , ("<Print>", spawn "import -window root $HOME/Pictures/Screenshots/$(date +%d%m%y%H%M%S).png")
        ]
        -- Appending search engine prompts to keybindings list.
        -- Look at "search engines" section of this config for values for "k".
        ++ [("M-s " ++ k, S.promptSearch dtXPConfig' f) | (k,f) <- searchList ]
        ++ [("M-S-s " ++ k, S.selectSearch f) | (k,f) <- searchList ]
        -- Appending some extra xprompts to keybindings list.
        -- Look at "xprompt settings" section this of config for values for "k".
        ++ [("M-p " ++ k, f dtXPConfig') | (k,f) <- promptList ]
        ++ [("M-p " ++ k, f dtXPConfig' g) | (k,f,g) <- promptList' ]
        -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

--------------------------
-- Main
--------------------------
main :: IO ()
main = do
    -- Get home directory
    myHome <- getHomeDirectory
    -- Launching single instance of xmobar
    -- Should look into creating multiple profiles
    -- if planning to get multiple monitors
    xmproc <- spawnPipe "xmobar $HOME/.config/xmonad/xmobarrc.hs"
    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh . docks $ def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput          = \x -> hPutStrLn xmproc x
                        , ppCurrent         = xmobarColor "#c3e88d" "" . wrap "[" "]"    -- Current workspace in xmobar
                        , ppVisible         = xmobarColor "#c3e88d" ""                   -- Visible but not current workspace
                        , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""     -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#F07178" ""                   -- Hidden workspaces (no windows)
                        , ppTitle           = xmobarColor "#d0d0d0" "" . shorten 60      -- Title of active window in xmobar
                        , ppSep             = "<fc=#666666> | </fc>"                     -- Separators in xmobar
                        , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!"    -- Urgent workspace
                        , ppExtras          = [windowCount]                              -- # of windows current workspace
                        , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
                    <+> wallpaperSetter defWallpaperConf
                        { wallpaperBaseDir = myHome </> "Pictures" </> "Wallpaper"
                        , wallpapers       = defWPNamesJpg myWorkspaces            -- TODO consider using defWPNamesPng in the future
                        }
        } `additionalKeysP` myKeys `removeKeysP` ["M-q"]
