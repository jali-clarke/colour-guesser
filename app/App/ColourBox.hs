module App.ColourBox
  ( ColourBox,
    new,
    element,
    setColour,
    setSelected,
  )
where

import Colour (Colour)
import Control.Monad (void)
import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core hiding (element)

newtype ColourBox = ColourBox {_element :: Element}

element :: ColourBox -> Element
element = _element

new :: UI ColourBox
new = do
  box <-
    UI.div
      # set
        UI.style
        [ ("height", "100px"),
          ("width", "100px"),
          ("color", "white"), -- text colour
          ("mix-blend-mode", "difference"), -- display text as negative colour
          ("padding", "1px"),
          ("border", "1px solid black")
        ]
  pure $ ColourBox box

setColour :: Colour -> ColourBox -> UI ()
setColour colour (ColourBox box) =
  void $
    pure box
      # set UI.style [("background-color", show colour)]
      # set UI.text (show colour)

setSelected :: Bool -> ColourBox -> UI ()
setSelected isSelected (ColourBox box) =
  void $ pure box # set UI.style [("border", if isSelected then "1px solid red" else "1px solid black")]
