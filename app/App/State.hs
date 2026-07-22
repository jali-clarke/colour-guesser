module App.State
  ( State,
    newState,
    setColours,
    allColours,
    toggleSelected,
    isSelected,
    resetSelected,
    numSelected,
    selectedColours,
  )
where

import Colour (Colour)
import qualified Data.IORef as IORef
import qualified Data.Set as Set
import qualified Data.Vector as Vector

newtype State = State (IORef.IORef State_)

data State_
  = State_
  { colours :: Vector.Vector Colour,
    selected :: Set.Set Int
  }

newState :: Vector.Vector Colour -> IO State
newState colours' = State <$> IORef.newIORef (State_ colours' Set.empty)

setColours :: Vector.Vector Colour -> State -> IO ()
setColours newColours (State ref) = IORef.modifyIORef ref $ \state -> state {colours = newColours}

allColours :: State -> IO (Vector.Vector Colour)
allColours (State ref) = colours <$> IORef.readIORef ref

toggleSelected :: Int -> State -> IO ()
toggleSelected boxIdx stateRef@(State ref) = do
  wasSelected <- isSelected boxIdx stateRef
  IORef.modifyIORef ref $ \state ->
    let selected' = selected state
     in state {selected = if wasSelected then Set.delete boxIdx selected' else Set.insert boxIdx selected'}

resetSelected :: State -> IO ()
resetSelected (State ref) = IORef.modifyIORef ref $ \state -> state {selected = Set.empty}

isSelected :: Int -> State -> IO Bool
isSelected boxIdx (State ref) = (Set.member boxIdx . selected) <$> IORef.readIORef ref

numSelected :: State -> IO Int
numSelected (State ref) = (Set.size . selected) <$> IORef.readIORef ref

selectedColours :: State -> IO [Colour]
selectedColours (State ref) = (\state -> fmap (colours state Vector.!) (Set.toList (selected state))) <$> IORef.readIORef ref
