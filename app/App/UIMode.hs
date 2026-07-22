module App.UIMode
  ( UIMode (..),
    uiModeReader,
  )
where

import Data.List (stripPrefix)
import Options.Applicative (ReadM, eitherReader)
import Text.Read (readMaybe)

data UIMode = Gtk | Threepenny (Maybe Int)

instance Show UIMode where
  show uiMode =
    case uiMode of
      Gtk -> "gtk"
      Threepenny maybePort ->
        case maybePort of
          Nothing -> "threepenny"
          Just port -> "threepenny:" <> show port

uiModeReader :: ReadM UIMode
uiModeReader =
  eitherReader $ \uiModeStr ->
    case uiModeStr of
      "gtk" -> Right Gtk
      "threepenny" -> Right (Threepenny Nothing)
      _ ->
        case stripPrefix "threepenny:" uiModeStr of
          Nothing -> Left $ "unknown gui mode: " <> uiModeStr
          Just portStr ->
            case readMaybe portStr of
              Nothing -> Left $ "invalid threepenny port: " <> portStr
              Just port -> Right (Threepenny (Just port))
