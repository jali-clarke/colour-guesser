{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk.ColourBox.Css
  ( baseBoxClass,
    selectedBoxClass,
    colouredBoxId,
    boxLabelClass,
    commonCss,
    boxColourCss,
  )
where

import Clay hiding (b)
import Colour (Colour (..))
import Data.Text (Text, pack)

baseBoxClass :: Text
baseBoxClass = "base-box"

selectedBoxClass :: Text
selectedBoxClass = "selected-box"

colouredBoxId :: Int -> Text
colouredBoxId boxIdx = "coloured-box-" <> pack (show boxIdx)

boxLabelClass :: Text
boxLabelClass = "box-label"

commonCss :: Css
commonCss = do
  byClass baseBoxClass & do
    padding (px 1) (px 1) (px 1) (px 1)
    border (px 1) solid black

  byClass selectedBoxClass & do
    border (px 1) solid red

  byClass boxLabelClass & do
    color black
    backgroundColor "#dcdcdc88"

boxColourCss :: Int -> Colour -> Css
boxColourCss boxIdx (Colour r g b) = do
  byId (colouredBoxId boxIdx) & do
    backgroundColor $ rgb (fromIntegral r) (fromIntegral g) (fromIntegral b)
