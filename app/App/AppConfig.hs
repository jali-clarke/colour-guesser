module App.AppConfig (
  AppConfig (..)
) where

import Colour (Colour)
import qualified Data.Vector as Vector
import UserChoice (UserChoice)

data AppConfig
  = AppConfig
  { maxSelectedColours :: Int,
    initialColours :: IO (Vector.Vector Colour),
    reportUserColours :: UserChoice -> IO (),
    newCandidateColours :: IO (Vector.Vector Colour),
    resetSimulation :: IO ()
  }
