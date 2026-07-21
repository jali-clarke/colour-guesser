module SimulationManager
  ( SimulationManager,
    startSimulation,
    restartSimulation,
    initialPopulation,
  )
where

import Colour (Colour)
import Control.Concurrent (ThreadId, forkIO, killThread)
import qualified Data.IORef as IORef
import qualified Data.Vector as Vector
import qualified Genetic
import Genetic.Positive (Positive)

data SimulationManager
  = SimulationManager
  { currentThreadRef :: IORef.IORef ThreadId,
    geneticOpts :: Genetic.GeneticOpts IO Colour,
    initialPopulationRef :: IORef.IORef (Vector.Vector Colour),
    simulateCallback :: Int -> Vector.Vector (Colour, Positive) -> IO Bool
  }

startSimulation :: Genetic.GeneticOpts IO Colour -> (Int -> Vector.Vector (Colour, Positive) -> IO Bool) -> IO SimulationManager
startSimulation geneticOpts' simulateCallback' = do
  currentThreadRef' <- IORef.newIORef undefined
  initialPopulationRef' <- IORef.newIORef undefined
  let manager = SimulationManager currentThreadRef' geneticOpts' initialPopulationRef' simulateCallback'
  initialize manager
  pure manager

restartSimulation :: SimulationManager -> IO ()
restartSimulation manager = do
  oldThreadId <- IORef.readIORef (currentThreadRef manager)
  killThread oldThreadId
  initialize manager

initialPopulation :: SimulationManager -> IO (Vector.Vector Colour)
initialPopulation manager = IORef.readIORef (initialPopulationRef manager)

initialize :: SimulationManager -> IO ()
initialize manager = do
  let geneticOpts' = geneticOpts manager
  initialPopulation' <- Genetic.newPopulation geneticOpts'
  IORef.writeIORef (initialPopulationRef manager) initialPopulation'
  threadId <- forkIO $ Genetic.simulate geneticOpts' initialPopulation' (simulateCallback manager)
  IORef.writeIORef (currentThreadRef manager) threadId
