{-# OPTIONS_GHC -Wno-orphans #-}

module Colour.Test () where

import Colour (Colour (..))
import Test.QuickCheck.Arbitrary

instance Arbitrary Colour where
  arbitrary = Colour <$> arbitrary <*> arbitrary <*> arbitrary
