{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module App.GiGtk
  ( AppConfig (..),
    UserChoice (..),
    app,
  )
where

import Colour (Colour)
import Control.Monad (void)
import Data.GI.Base
import qualified Data.Vector as Vector
import qualified GI.Gtk as Gtk

data AppConfig
  = AppConfig
  { maxSelectedColours :: Int,
    initialColours :: IO (Vector.Vector Colour),
    reportUserColours :: UserChoice -> IO (),
    newCandidateColours :: IO (Vector.Vector Colour),
    resetSimulation :: IO ()
  }

data UserChoice
  = UserChose [Colour]
  | UserDislikes [Colour]

app :: AppConfig -> IO ()
app _ = do
  gtkApp <- new Gtk.Application [#applicationId := "colour-guesser"]
  void $ gtkApp.run Nothing
