module App.Threepenny
  ( AppConfig (..),
    app,
  )
where

import App.AppConfig (AppConfig (..))
import qualified App.State as State
import qualified App.Threepenny.ColourBox as ColourBox
import Colour (Colour)
import Control.Monad (forM_, replicateM, void)
import qualified Data.Vector as Vector
import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core
import UserChoice (UserChoice (..))

app :: Maybe Int -> AppConfig -> IO ()
app maybeListenPort appConfig = startGUI (defaultConfig {jsPort = maybeListenPort}) (setup appConfig)

setup :: AppConfig -> Window -> UI ()
setup appConfig window = do
  _ <- pure window # set title "colour guesser"

  body <- getBody window
  _ <- pure body # set UI.style [("background-color", "black")]

  initialColours' <- liftIO $ initialColours appConfig
  let numInitialColours = Vector.length initialColours'

  state <- liftIO $ State.newState initialColours'

  candidateBoxes <- replicateM numInitialColours ColourBox.new
  updateCandidateColours candidateBoxes initialColours'

  forM_ (zip [0 ..] candidateBoxes) $ \(idx, box) ->
    on UI.click (ColourBox.element box) $ \_ -> do
      maybeNewColours <- liftIO $ do
        State.toggleSelected state idx
        numSelected <- State.numSelected state

        if numSelected >= maxSelectedColours appConfig
          then do
            selectedColours <- State.selectedColours state
            reportUserColours appConfig (UserChose selectedColours)
            State.resetSelected state
            newColours <- newCandidateColours appConfig
            State.setColours state newColours
            pure $ Just newColours
          else pure Nothing

      case maybeNewColours of
        Nothing -> do
          isSelected <- liftIO $ State.isSelected state idx
          box # ColourBox.setSelected isSelected
        Just newColours -> do
          updateCandidateColours candidateBoxes newColours

  resetButton <- UI.button # set UI.text "reset"

  on UI.click resetButton $ \_ -> do
    newInitialColours <-
      liftIO $ do
        resetSimulation appConfig
        newInitialColours <- initialColours appConfig
        State.setColours state newInitialColours
        State.resetSelected state
        pure newInitialColours

    updateCandidateColours candidateBoxes newInitialColours

  rejectAllButton <- UI.button # set UI.text "i don't like any of these"

  on UI.click rejectAllButton $ \_ -> do
    newColours <- liftIO $ do
      rejectedColours <- State.allColours state
      reportUserColours appConfig (UserDislikes $ Vector.toList rejectedColours)
      State.resetSelected state
      newColours <- newCandidateColours appConfig
      State.setColours state newColours
      pure newColours

    updateCandidateColours candidateBoxes newColours

  let layout = grid . chunkList ((numInitialColours + 3) `div` 4) $ fmap (element . ColourBox.element) candidateBoxes
  void $ getBody window #+ [layout, element rejectAllButton, element resetButton]

updateCandidateColours :: [ColourBox.ColourBox] -> Vector.Vector Colour -> UI ()
updateCandidateColours boxes colours = do
  forM_ (zip boxes (Vector.toList colours)) $ \(box, colour) -> do
    void $ box # ColourBox.setColour colour
    box # ColourBox.setSelected False

chunkList :: Int -> [a] -> [[a]]
chunkList chunkSize xs =
  case xs of
    [] -> []
    _ ->
      let (chunk, rest) = splitAt chunkSize xs
       in chunk : chunkList chunkSize rest
