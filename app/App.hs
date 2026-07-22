module App (
  runApp
) where

import App.UIMode (UIMode (..))
import App.AppConfig (AppConfig (..))
import qualified App.GiGtk as GiGtk
import qualified App.Threepenny as Threepenny

runApp :: UIMode -> AppConfig -> IO ()
runApp uiMode =
  case uiMode of
    Gtk -> GiGtk.app
    Threepenny maybeListenPort -> Threepenny.app maybeListenPort

