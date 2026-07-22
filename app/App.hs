module App
  ( runApp,
  )
where

import App.AppConfig (AppConfig (..))
import qualified App.GiGtk as GiGtk
import qualified App.Threepenny as Threepenny
import App.UIMode (UIMode (..))

runApp :: UIMode -> AppConfig -> IO ()
runApp uiMode =
  case uiMode of
    Gtk -> GiGtk.app
    Threepenny maybeListenPort -> Threepenny.app maybeListenPort
