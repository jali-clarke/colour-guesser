module Main where

import qualified App
import qualified CLI
import Colour (Colour (..))
import qualified Control.Concurrent.MVar as MVar
import qualified Data.Vector as Vector
import qualified Genetic
import Genetic.Positive (Positive, abs', square)
import qualified MVarN
import qualified SimulationManager

main :: IO ()
main = do
  opts <- CLI.getOpts

  candidateColoursMVar <- MVar.newEmptyMVar
  userChoiceMVar <- MVarN.newEmptyMVarN

  let geneticOpts =
        CLI.mkGeneticOpts opts $ \candidate -> do
          userChoice <- MVarN.takeMVarN userChoiceMVar 1
          case userChoice of
            App.UserChose selectedColours -> pure $ 1 / ((sum $ fmap (diffColourSq candidate) selectedColours) + 0.1)
            App.UserDislikes dislikedColours -> pure $ sum (fmap (diffColourSq candidate) dislikedColours)

  let numCandidateColoursDisplay = CLI.numCandidateColoursDisplay opts

  manager <- SimulationManager.startSimulation geneticOpts (simulateCallback numCandidateColoursDisplay candidateColoursMVar)

  App.app $
    App.AppConfig
      { App.listenPort = CLI.listenPort opts,
        App.maxSelectedColours = CLI.maxSelectedColours opts,
        App.initialColours = do
          initialPopulation' <- SimulationManager.initialPopulation manager
          pure (Vector.take numCandidateColoursDisplay initialPopulation'),
        App.reportUserColours = MVarN.putMVarN userChoiceMVar (Genetic.populationSize geneticOpts),
        App.newCandidateColours = MVar.takeMVar candidateColoursMVar,
        App.resetSimulation = SimulationManager.restartSimulation manager
      }

diffColourSq :: Colour -> Colour -> Positive
diffColourSq (Colour r0 b0 g0) (Colour r1 b1 g1) =
  square (abs' (fromIntegral r0 - fromIntegral r1))
    + square (abs' (fromIntegral g0 - fromIntegral g1))
    + square (abs' (fromIntegral b0 - fromIntegral b1))

simulateCallback :: Int -> MVar.MVar (Vector.Vector Colour) -> Int -> Vector.Vector (Colour, Positive) -> IO Bool
simulateCallback numCandidateColours candidateColoursMVar _ colours = do
  let candidates = fmap fst $ Vector.take numCandidateColours colours
  MVar.putMVar candidateColoursMVar candidates
  pure True
