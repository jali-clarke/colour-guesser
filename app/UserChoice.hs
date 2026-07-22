module UserChoice
  ( UserChoice (..),
  )
where

import Colour (Colour)

data UserChoice
  = UserChose [Colour]
  | UserDislikes [Colour]
