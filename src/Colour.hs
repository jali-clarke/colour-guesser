{-# LANGUAGE TypeFamilies #-}

module Colour
  ( Colour (..),
  )
where

import qualified Control.Monad.Random as Random
import Data.Bits (complement, (.&.), (.|.))
import Data.Word (Word8)
import Genetic (Genetic (..), Mutatable (..))
import Genetic.Zipperable (Zipperable (..))
import Text.Printf (printf)

data Colour = Colour Word8 Word8 Word8
  deriving (Eq)

instance Show Colour where
  show (Colour r g b) = printf "#%02x%02x%02x" r g b

data ColourPatches = ColourPatches (Word8, Word8) (Word8, Word8) (Word8, Word8)

applyPatchChannel :: Word8 -> Word8 -> Word8 -> Word8
applyPatchChannel mask original new = (complement mask .&. original) .|. (mask .&. new)

applyPatches :: ColourPatches -> Colour -> Colour
applyPatches (ColourPatches (rMask, rApply) (gMask, gApply) (bMask, bApply)) (Colour r g b) =
  Colour
    (applyPatchChannel rMask r rApply)
    (applyPatchChannel gMask g gApply)
    (applyPatchChannel bMask b bApply)

instance Zipperable Colour where
  type Hole Colour = ColourPatches

  split c@(Colour r g b) = do
    (rMask, gMask, bMask) <- Random.getRandom
    pure $ (flip applyPatches c, ColourPatches (rMask, r) (gMask, g) (bMask, b))

instance Mutatable ColourPatches where
  mutate (ColourPatches (rMask, rApply) (gMask, gApply) (bMask, bApply)) = do
    (rPatchModColour, gPatchModColour, bPatchModColour) <- Random.getRandom
    (rPatchModMask, gPatchModMask, bPatchModMask) <- Random.getRandom
    pure $
      ColourPatches
        (rMask, applyPatchChannel rPatchModMask rApply rPatchModColour)
        (gMask, applyPatchChannel gPatchModMask gApply gPatchModColour)
        (bMask, applyPatchChannel bPatchModMask bApply bPatchModColour)

instance Mutatable Colour

instance Genetic Colour where
  generateNew = Colour <$> Random.getRandom <*> Random.getRandom <*> Random.getRandom
