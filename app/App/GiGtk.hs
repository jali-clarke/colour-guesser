{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk
  ( AppConfig (..),
    app,
  )
where

import qualified App.GiGtk.Css as Css
import Colour (Colour)
import Control.Monad (void)
import qualified Data.Vector as Vector
import qualified GI.Gio as Gio
import qualified GI.Gtk as Gtk
import UserChoice (UserChoice)

data AppConfig
  = AppConfig
  { maxSelectedColours :: Int,
    initialColours :: IO (Vector.Vector Colour),
    reportUserColours :: UserChoice -> IO (),
    newCandidateColours :: IO (Vector.Vector Colour),
    resetSimulation :: IO ()
  }

activateGtkApp :: AppConfig -> Gtk.Application -> IO ()
activateGtkApp _ gtkApp = do
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

  Gtk.windowPresent window

app :: AppConfig -> IO ()
app appConfig = do
  gtkApp <- Gtk.applicationNew (Just "colour-guesser") []
  void $ Gio.onApplicationActivate gtkApp (activateGtkApp appConfig gtkApp)
  void $ Gio.applicationRun gtkApp Nothing
