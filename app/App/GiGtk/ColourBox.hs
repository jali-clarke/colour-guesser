{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk.ColourBox
  ( ColourBox,
    ColourBoxSetup,
    setupCommonCss,
    new,
    setColour,
    setSelected,
  )
where

import qualified App.GiGtk.ColourBox.Css as Css
import Colour (Colour)
import qualified Data.Text as Text
import qualified GI.Gdk as Gdk
import qualified GI.Gtk as Gtk

data ColourBox
  = ColourBox
  { _box :: Gtk.Box,
    _label :: Gtk.Label,
    _boxIdx :: Int,
    _boxCssProvider :: Gtk.CssProvider
  }

data ColourBoxSetup = ColourBoxSetup

setupCommonCss :: Gdk.Display -> IO ColourBoxSetup
setupCommonCss display = do
  allBoxesProvider <- Gtk.cssProviderNew
  Gtk.cssProviderLoadFromString
    allBoxesProvider
    (Css.toText Css.commonCss)

  Gtk.styleContextAddProviderForDisplay
    display
    allBoxesProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure ColourBoxSetup

new :: ColourBoxSetup -> Gdk.Display -> Int -> IO ColourBox
new _ display boxIdx = do
  box <- Gtk.new Gtk.Box []
  Gtk.widgetSetSizeRequest box 100 100
  Gtk.widgetAddCssClass box Css.baseBoxClass
  Gtk.widgetSetName box (Css.colouredBoxId boxIdx)

  label <- Gtk.new Gtk.Label []
  Gtk.widgetAddCssClass label Css.boxLabelClass

  boxCssProvider <- Gtk.cssProviderNew
  Gtk.styleContextAddProviderForDisplay
    display
    boxCssProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure $ ColourBox box label boxIdx boxCssProvider

setColour :: ColourBox -> Colour -> IO ()
setColour (ColourBox _ label boxIdx boxCssProvider) colour = do
  Gtk.cssProviderLoadFromString
    boxCssProvider
    (Css.toText $ Css.boxColourCss boxIdx colour)

  Gtk.labelSetText label $ Text.pack (show colour)

setSelected :: ColourBox -> Bool -> IO ()
setSelected (ColourBox box _ _ _) isSelected =
  if isSelected
    then Gtk.widgetAddCssClass box Css.selectedBoxClass
    else Gtk.widgetRemoveCssClass box Css.selectedBoxClass
