{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk
  ( AppConfig (..),
    app,
  )
where

import App.AppConfig (AppConfig (..))
import qualified App.GiGtk.ColourBox as ColourBox
import qualified App.GiGtk.Css as Css
import Colour (Colour)
import Control.Monad (forM, forM_, void)
import qualified Data.Vector as Vector
import qualified GI.Gio as Gio
import qualified GI.Gtk as Gtk

activateGtkApp :: AppConfig -> Gtk.Application -> IO ()
activateGtkApp appConfig gtkApp = do
  window <- Gtk.applicationWindowNew gtkApp
  Gtk.windowSetTitle window (Just "colour guesser")

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
  let numBoxesRows = 4

  mkColourBox <- ColourBox.initColourBoxConstructor display

  initialColours' <- initialColours appConfig
  colourBoxes <-
    forM [0 .. Vector.length initialColours' - 1] $ \boxIdx -> do
      colourBox <- mkColourBox boxIdx
      let (colIdx, rowIdx) = fromIntegral boxIdx `divMod` numBoxesRows
      Gtk.gridAttach grid (ColourBox.asWidget colourBox) colIdx rowIdx 1 1
      pure colourBox

  updateCandidateColours colourBoxes initialColours'

  resetButton <- Gtk.buttonNewWithLabel "reset"
  Gtk.gridAttach grid resetButton 0 (numBoxesRows + 1) 1 1

  void . Gtk.onButtonClicked resetButton $ do
    resetSimulation appConfig
    newInitialColours <- initialColours appConfig
    updateCandidateColours colourBoxes newInitialColours

  rejectAllButton <- Gtk.buttonNewWithLabel "i don't like any of these"
  Gtk.gridAttach grid rejectAllButton 1 (numBoxesRows + 1) 2 1

  Gtk.windowPresent window

updateCandidateColours :: [ColourBox.ColourBox] -> Vector.Vector Colour -> IO ()
updateCandidateColours boxes colours = do
  forM_ (zip boxes (Vector.toList colours)) $ \(box, colour) -> do
    ColourBox.setColour box colour
    ColourBox.setSelected box False

app :: AppConfig -> IO ()
app appConfig = do
  gtkApp <- Gtk.applicationNew Nothing []
  void $ Gio.onApplicationActivate gtkApp (activateGtkApp appConfig gtkApp)
  void $ Gio.applicationRun gtkApp Nothing
