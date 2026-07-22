module App.UIMode (
  UIMode (..)
) where

data UIMode = Gtk | Threepenny (Maybe Int)

instance Show UIMode where
  show uiMode =
    case uiMode of
      Gtk -> "gtk"
      Threepenny maybePort ->
        case maybePort of
          Nothing -> "threepenny"
          Just port -> "threepenny:" <> show port
