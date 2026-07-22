{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk
  ( AppConfig (..),
    app,
  )
where

import App.AppConfig (AppConfig (..))
import qualified App.GiGtk.ColourBox as ColourBox
import qualified App.GiGtk.Css as Css
import Control.Monad (forM_, void)
import qualified Data.Vector as Vector
import qualified GI.Gio as Gio
import qualified GI.Gtk as Gtk

activateGtkApp :: AppConfig -> Gtk.Application -> IO ()
activateGtkApp appConfig gtkApp = do
  window <- Gtk.applicationWindowNew gtkApp
  Gtk.windowSetTitle window (Just "colour guesser")
  Gtk.windowSetDefaultSize window 500 800

  display <- Gtk.widgetGetDisplay window

  cssProvider <- Gtk.cssProviderNew
  Gtk.styleContextAddProviderForDisplay
    display
    cssProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  Gtk.cssProviderLoadFromString
    cssProvider
    (Css.toText Css.backgroundCss)

  grid <- Gtk.gridNew
  Gtk.windowSetChild window (Just grid)

  mkColourBox <- ColourBox.initColourBoxConstructor display

  initialColours' <- initialColours appConfig
  forM_ [0 .. Vector.length initialColours'] $ \boxIdx -> do
    colourBox <- mkColourBox boxIdx
    let (colIdx, rowIdx) = fromIntegral boxIdx `divMod` 4
    Gtk.gridAttach grid (ColourBox.asWidget colourBox) colIdx rowIdx 1 1
    ColourBox.setColour colourBox (initialColours' Vector.! boxIdx)

  Gtk.windowPresent window

app :: AppConfig -> IO ()
app appConfig = do
  gtkApp <- Gtk.applicationNew (Just "colour-guesser") []
  void $ Gio.onApplicationActivate gtkApp (activateGtkApp appConfig gtkApp)
  void $ Gio.applicationRun gtkApp Nothing
