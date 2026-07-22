{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk.ColourBox
  ( ColourBox,
    asWidget,
    initColourBoxConstructor,
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

asWidget :: ColourBox -> Gtk.Box
asWidget (ColourBox box _ _ _) = box

initColourBoxConstructor :: Gdk.Display -> IO (Int -> IO ColourBox)
initColourBoxConstructor display = do
  allBoxesProvider <- Gtk.cssProviderNew
  Gtk.cssProviderLoadFromString
    allBoxesProvider
    (Css.toText Css.commonCss)

  Gtk.styleContextAddProviderForDisplay
    display
    allBoxesProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure (newColourBox display)

newColourBox :: Gdk.Display -> Int -> IO ColourBox
newColourBox display boxIdx = do
  box <- Gtk.boxNew Gtk.OrientationVertical 0
  Gtk.widgetSetSizeRequest box 100 100
  Gtk.widgetAddCssClass box Css.baseBoxClass
  Gtk.widgetSetName box (Css.colouredBoxId boxIdx)
  boxCssProvider <- Gtk.cssProviderNew
  Gtk.styleContextAddProviderForDisplay
    display
    boxCssProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  label <- Gtk.labelNew Nothing
  Gtk.widgetAddCssClass label Css.boxLabelClass

  Gtk.boxPrepend box label

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
