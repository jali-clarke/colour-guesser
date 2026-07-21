module App
  ( AppConfig (..),
    app,
  )
where

import qualified App.ColourBox as ColourBox
import qualified App.State as State
import Colour (Colour)
import Control.Monad (forM_, replicateM, void)
import qualified Data.Vector as Vector
import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core

data AppConfig
  = AppConfig
  { maxSelectedColours :: Int,
    initialColours :: Vector.Vector Colour,
    reportUserColours :: [Colour] -> IO (),
    newCandidateColours :: IO (Vector.Vector Colour)
  }

app :: AppConfig -> IO ()
app appConfig = startGUI (defaultConfig {jsPort = Just 8080}) (setup appConfig)

setup :: AppConfig -> Window -> UI ()
setup appConfig window = do
  _ <- pure window # set title "colour guesser"

  body <- getBody window
  _ <- pure body # set UI.style [("background-color", "black")]

  let initialColours' = initialColours appConfig
      numInitialColours = Vector.length initialColours'

  state <- liftIO $ State.newState initialColours'

  candidateBoxes <- replicateM numInitialColours ColourBox.new
  updateCandidateColours candidateBoxes initialColours'

  forM_ (zip [0 ..] candidateBoxes) $ \(idx, box) ->
    on UI.click (ColourBox.element box) $ \_ -> do
      maybeNewColours <- liftIO $ do
        State.toggleSelected idx state
        numSelected <- State.numSelected state

        if numSelected >= maxSelectedColours appConfig
          then do
            selectedColours <- State.selectedColours state
            reportUserColours appConfig selectedColours
            State.resetSelected state
            newColours <- newCandidateColours appConfig
            State.setColours newColours state
            pure $ Just newColours
          else do
            pure Nothing

      case maybeNewColours of
        Nothing -> do
          isSelected <- liftIO $ State.isSelected idx state
          box # ColourBox.setSelected isSelected
        Just newColours -> do
          updateCandidateColours candidateBoxes newColours
          forM_ candidateBoxes $ ColourBox.setSelected False

  let layout = grid . chunkList ((numInitialColours + 3) `div` 4) $ fmap (element . ColourBox.element) candidateBoxes
  void $ getBody window #+ [layout]

updateCandidateColours :: [ColourBox.ColourBox] -> Vector.Vector Colour -> UI ()
updateCandidateColours boxes colours =
  forM_ (zip boxes (Vector.toList colours)) $ \(box, colour) -> void $ box # ColourBox.setColour colour

chunkList :: Int -> [a] -> [[a]]
chunkList chunkSize xs =
  case xs of
    [] -> []
    _ ->
      let (chunk, rest) = splitAt chunkSize xs
       in chunk : chunkList chunkSize rest
