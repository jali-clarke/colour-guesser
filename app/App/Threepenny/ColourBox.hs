module App.Threepenny.ColourBox
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
import Prelude hiding (span)

data ColourBox = ColourBox {_element :: Element, _span :: Element}

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
          ("padding", "1px"),
          ("border", "1px solid black")
        ]
  span <-
    UI.span
      # set
        UI.style
        [ ("color", "black"),
          ("background-color", "#dcdcdc88")
        ]
  void $ pure box #+ [UI.element span]
  pure $ ColourBox box span

setColour :: Colour -> ColourBox -> UI ()
setColour colour (ColourBox box span) = do
  void $ pure box # set UI.style [("background-color", show colour)]
  void $ pure span # set UI.text (show colour)

setSelected :: Bool -> ColourBox -> UI ()
setSelected isSelected (ColourBox box _) =
  void $ pure box # set UI.style [("border", if isSelected then "1px solid red" else "1px solid black")]
