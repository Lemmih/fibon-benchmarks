module Main(main) where

import Control.Monad
import ExHeap
import ExLambda
import ExMerge
import ExSet
import ExSimple
--import ExTrie
--import ExWeird
--import Example1
--import Example2
import System.Environment
import System.Random
import Test.QuickCheck.Test

import Fibon.Run.BenchmarkHelper

main = fibonMain oldmain

oldmain 0 = return ()
oldmain n = do
  cnt <- parseArgs
  let   
      stdgen = mkStdGen 42
      args   = stdArgs {chatty = False,
                        replay = Just (stdgen, 1),
                        maxSuccess = cnt}

  forM_ [   ExHeap.run
          , ExLambda.run
          , ExSet.run
          , ExSimple.run
          , ExMerge.run
        ] 
    $ \t -> t args
  when (n == 1) $ putStrLn "Ok"
  oldmain (n-1)

parseArgs = do {
  args <- getArgs
  ;let cnt = case args of
            []    -> defaultCount
            (x:_) -> case reads x of [(n,"")] -> n; _ -> defaultCount 
  in 
  return cnt}
  where defaultCount = 100

