module Main where

import qualified App
import qualified CLI
import Colour (Colour (..))
import Control.Concurrent (forkIO)
import qualified Control.Concurrent.MVar as MVar
import qualified Data.Vector as Vector
import qualified Genetic
import Genetic.Positive (Positive, abs', square)
import qualified MVarN

main :: IO ()
main = do
  opts <- CLI.getOpts

  candidateColoursMVar <- MVar.newEmptyMVar
  userListMVar <- MVarN.newEmptyMVarN

  let geneticOpts =
        CLI.mkGeneticOpts opts $ \candidate -> do
          selectedColours <- MVarN.takeMVarN userListMVar 1
          pure $ 1 / ((sum $ fmap (diffColourSq candidate) selectedColours) + 0.1)

  initialPopulation <- Genetic.newPopulation geneticOpts
  let numCandidateColoursDisplay = CLI.numCandidateColoursDisplay opts

  _ <- forkIO $ Genetic.simulate geneticOpts initialPopulation (simulateCallback numCandidateColoursDisplay candidateColoursMVar)

  App.app $
    App.AppConfig
      { App.maxSelectedColours = CLI.maxSelectedColours opts,
        App.initialColours = pure (Vector.take numCandidateColoursDisplay initialPopulation),
        App.reportUserColours = MVarN.putMVarN userListMVar (Genetic.populationSize geneticOpts),
        App.newCandidateColours = MVar.takeMVar candidateColoursMVar
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
