{-# LANGUAGE ApplicativeDo #-}

module CLI
  ( Opts (..),
    getOpts,
  )
where

import Colour (Colour)
import qualified Genetic
import Genetic.Positive (Positive, abs')
import Options.Applicative

data Opts
  = Opts
  { listenPort :: Int,
    maxSelectedColours :: Int,
    numCandidateColoursDisplay :: Int,
    mkGeneticOpts :: (Colour -> IO Positive) -> Genetic.GeneticOpts IO Colour
  }

getOpts :: IO Opts
getOpts = execParser (info (parser <**> helper) mempty)

parser :: Parser Opts
parser = do
  listenPort' <-
    option auto (showDefault <> value 8080 <> long "port" <> short 'p' <> help "port on which to serve the threepenny-gui")
  maxSelectedColours' <-
    option auto (showDefault <> value 3 <> long "max-selected-colours" <> short 'm' <> help "number of colours able to be selected before next generation runs")
  numCandidateColoursDisplay' <-
    option auto (showDefault <> value 20 <> long "num-candidate-colours-display" <> short 'n' <> help "number of colours to display for selection")
  populationSize' <-
    option auto (showDefault <> value 50 <> long "population-size" <> short 's' <> help "number of colours that are mixed together in the backend")
  numElites' <-
    option auto (showDefault <> value 1 <> long "num-elites" <> short 'e' <> help "number of colours passed through directly to the next generation")
  replicateWeight' <-
    option positive (showDefault <> value 0 <> long "replicate-weight" <> help "relative weight for replicate genetic operation")
  crossoverWeight' <-
    option positive (showDefault <> value 0.5 <> long "crossover-weight" <> help "relative weight for crossover genetic operation")
  mutateWeight' <-
    option positive (showDefault <> value 0.5 <> long "mutate-weight" <> help "relative weight for mutate genetic operation")

  pure $
    Opts
      { listenPort = listenPort',
        maxSelectedColours = maxSelectedColours',
        numCandidateColoursDisplay = numCandidateColoursDisplay',
        mkGeneticOpts = \fitness' ->
          Genetic.GeneticOpts
            { Genetic.populationSize = populationSize',
              Genetic.fitness = fitness',
              Genetic.numElites = numElites',
              Genetic.replicateWeight = replicateWeight',
              Genetic.crossoverWeight = crossoverWeight',
              Genetic.mutateWeight = mutateWeight'
            }
      }

positive :: ReadM Positive
positive = abs' <$> auto
