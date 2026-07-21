module Main where

import Colour (Colour (..))
import Colour.Test ()
import Genetic.Zipperable (split)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)

main :: IO ()
main = hspec $ do
  describe "Colour" $ do
    describe "split" $ do
      prop "recombines faithfully" $ \(c :: Colour) -> do
        (ctx, patch) <- split c
        ctx patch `shouldBe` c
