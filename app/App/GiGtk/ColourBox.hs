{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk.ColourBox
  ( ColourBox,
    sideLength,
    asWidget,
    initColourBoxConstructor,
    setColour,
    setSelected,
    setOnClickCallback,
  )
where

import qualified App.GiGtk.ColourBox.Css as Css
import App.GiGtk.Css (toText)
import Colour (Colour)
import Control.Monad (void)
import qualified Data.Text as Text
import qualified GHC.Int
import qualified GI.Gdk as Gdk
import qualified GI.Gtk as Gtk

data ColourBox
  = ColourBox
  { _box :: Gtk.Box,
    _label :: Gtk.Label,
    _boxIdx :: Int,
    _gestureClick :: Gtk.GestureClick,
    _boxCssProvider :: Gtk.CssProvider
  }

asWidget :: ColourBox -> Gtk.Box
asWidget (ColourBox box _ _ _ _) = box

sideLength :: GHC.Int.Int32
sideLength = 100

initColourBoxConstructor :: Gdk.Display -> IO (Int -> IO ColourBox)
initColourBoxConstructor display = do
  allBoxesProvider <- Gtk.cssProviderNew
  Gtk.cssProviderLoadFromString
    allBoxesProvider
    (toText Css.commonCss)

  Gtk.styleContextAddProviderForDisplay
    display
    allBoxesProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  pure (newColourBox display)

newColourBox :: Gdk.Display -> Int -> IO ColourBox
newColourBox display boxIdx = do
  box <- Gtk.boxNew Gtk.OrientationVertical 0
  Gtk.widgetSetSizeRequest box sideLength sideLength
  Gtk.widgetAddCssClass box Css.baseBoxClass
  Gtk.widgetSetName box (Css.colouredBoxId boxIdx)
  boxCssProvider <- Gtk.cssProviderNew
  Gtk.styleContextAddProviderForDisplay
    display
    boxCssProvider
    (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

  gestureClick <- Gtk.gestureClickNew
  Gtk.widgetAddController box gestureClick

  label <- Gtk.labelNew Nothing
  Gtk.widgetAddCssClass label Css.boxLabelClass

  Gtk.boxPrepend box label

  pure $ ColourBox box label boxIdx gestureClick boxCssProvider

setColour :: ColourBox -> Colour -> IO ()
setColour (ColourBox _ label boxIdx _ boxCssProvider) colour = do
  Gtk.cssProviderLoadFromString
    boxCssProvider
    (toText $ Css.boxColourCss boxIdx colour)

  Gtk.labelSetText label $ Text.pack (show colour)

setSelected :: ColourBox -> Bool -> IO ()
setSelected (ColourBox box _ _ _ _) isSelected =
  if isSelected
    then Gtk.widgetAddCssClass box Css.selectedBoxClass
    else Gtk.widgetRemoveCssClass box Css.selectedBoxClass

setOnClickCallback :: ColourBox -> IO () -> IO ()
setOnClickCallback (ColourBox _ _ _ gestureClick _) callback =
  void $ Gtk.onGestureClickReleased gestureClick (\_ _ _ -> callback)
