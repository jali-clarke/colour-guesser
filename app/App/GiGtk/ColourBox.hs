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

import qualified Clay
import Colour (Colour (..))
import qualified Data.Text as Text
import qualified Data.Text.Lazy
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

baseBoxClass :: Text.Text
baseBoxClass = "base-box"

selectedBoxClass :: Text.Text
selectedBoxClass = "selected-box"

colouredBoxId :: Int -> Text.Text
colouredBoxId boxIdx = "coloured-box-" <> Text.pack (show boxIdx)

boxLabelClass :: Text.Text
boxLabelClass = "box-label"

setupCommonCss :: Gdk.Display -> IO ColourBoxSetup
setupCommonCss display = do
  allBoxesProvider <- Gtk.cssProviderNew
  Gtk.cssProviderLoadFromString
    allBoxesProvider
    ( Data.Text.Lazy.toStrict . Clay.render $ do
        Clay.byClass baseBoxClass Clay.& do
          Clay.padding (Clay.px 1) (Clay.px 1) (Clay.px 1) (Clay.px 1)
          Clay.border (Clay.px 1) Clay.solid Clay.black

        Clay.byClass selectedBoxClass Clay.& do
          Clay.border (Clay.px 1) Clay.solid Clay.red

        Clay.byClass boxLabelClass Clay.& do
          Clay.color Clay.black
          Clay.backgroundColor "#dcdcdc88"
    )

  Gtk.styleContextAddProviderForDisplay
    display
    allBoxesProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure ColourBoxSetup

new :: ColourBoxSetup -> Gdk.Display -> Int -> IO ColourBox
new _ display boxIdx = do
  box <- Gtk.new Gtk.Box []
  Gtk.widgetSetSizeRequest box 100 100
  Gtk.widgetAddCssClass box baseBoxClass
  Gtk.widgetSetName box (colouredBoxId boxIdx)

  label <- Gtk.new Gtk.Label []
  Gtk.widgetAddCssClass label boxLabelClass

  boxCssProvider <- Gtk.cssProviderNew
  Gtk.styleContextAddProviderForDisplay
    display
    boxCssProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure $ ColourBox box label boxIdx boxCssProvider

setColour :: ColourBox -> Colour -> IO ()
setColour (ColourBox _ label boxIdx boxCssProvider) colour@(Colour r g b) = do
  Gtk.cssProviderLoadFromString
    boxCssProvider
    ( Data.Text.Lazy.toStrict . Clay.render $ do
        Clay.byId (colouredBoxId boxIdx) Clay.& do
          Clay.backgroundColor $ Clay.rgb (fromIntegral r) (fromIntegral g) (fromIntegral b)
    )

  Gtk.labelSetText label $ Text.pack (show colour)

setSelected :: ColourBox -> Bool -> IO ()
setSelected (ColourBox box _ _ _) isSelected =
  if isSelected
    then Gtk.widgetAddCssClass box selectedBoxClass
    else Gtk.widgetRemoveCssClass box selectedBoxClass
