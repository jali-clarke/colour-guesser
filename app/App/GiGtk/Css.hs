{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk.Css
  ( backgroundClass,
    backgroundCss,
    toText,
  )
where

import Clay
import Data.Text (Text)
import Data.Text.Lazy (toStrict)

toText :: Css -> Text
toText = toStrict . render

backgroundClass :: Text
backgroundClass = "background"

backgroundCss :: Css
backgroundCss = do
  byClass backgroundClass & do
    backgroundColor black
