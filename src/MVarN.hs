module MVarN
  ( MVarN,
    newEmptyMVarN,
    takeMVarN,
    putMVarN,
  )
where

import qualified Control.Concurrent.QSemN as QSemN
import qualified Data.IORef as IORef

data MVarN a = MVarN QSemN.QSemN (IORef.IORef a)

newEmptyMVarN :: IO (MVarN a)
newEmptyMVarN = MVarN <$> QSemN.newQSemN 0 <*> IORef.newIORef undefined

takeMVarN :: MVarN a -> Int -> IO a
takeMVarN (MVarN sem ref) n = do
  QSemN.waitQSemN sem n
  IORef.readIORef ref

putMVarN :: MVarN a -> Int -> a -> IO ()
putMVarN (MVarN sem ref) n a = do
  IORef.writeIORef ref a
  QSemN.signalQSemN sem n
