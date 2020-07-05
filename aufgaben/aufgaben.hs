{-# LANGUAGE QuasiQuotes #-}
module Main where

import Prelude hiding (putStr)
import Test.QuickCheck
import Data.Text.Lazy.Builder
import Data.Text.Lazy
import Data.Text.Lazy.IO
import System.Environment

data Op = Add | Mul | Div | Sub

instance Show Op where
  show Add = "+"
  show Mul = "\\cdot{}"
  show Div = ":"
  show Sub = "-"

instance Arbitrary Op where
  arbitrary = elements [ Add, Mul, Div, Sub ]

data Problem = Problem Int Op Int

instance Show Problem where
  show (Problem f op g) = show f <> show op <> show g <> "&=\\hspace{60pt}"

instance Arbitrary Problem where
  arbitrary = do
    op <- arbitrary
    f <- case op of
       Add -> choose (1::Int, 99::Int)
       Mul -> choose (1::Int, 10::Int)
       Div -> choose (1::Int, 99::Int)
       Sub -> choose (1::Int, 99::Int)
    g <- case op of
       Add -> choose (1::Int, 99::Int)
       Mul -> choose (1::Int, 10::Int)
       Div -> choose (1::Int, 10::Int)
       Sub -> choose (1::Int, f)
    return (Problem f op g)

showProblemsI :: Int -> [Problem] -> Builder -> Text
showProblemsI _     [] b = toLazyText (b <> fromString "\\\\\n")
showProblemsI 2 (x:xs) b = showProblemsI     0 xs (b <> fromString "\\\\\n\\\\\n" <> fromString (show x))
showProblemsI n (x:xs) b = showProblemsI (n+1) xs (b <> fromString "&" <> fromString (show x))

showProblems :: [Problem] -> Text
showProblems []     = mempty
showProblems (x:xs) = showProblemsI 0 xs (fromString (show x))

genProbs :: Int -> [Problem] -> IO [Problem]
genProbs 0 probs = return probs
genProbs n probs = do
  prob <- generate arbitrary
  genProbs (n-1) (prob:probs)

printHeader = toLazyText (
  fromString "\\documentclass[fontsize=14pt]{scrartcl}\n"<>
  fromString "\n"<>
  fromString "\\usepackage{amsmath}\n"<> 
  fromString "\n"<>
  fromString "\\begin{document}\n"<>
  fromString "\\begin{alignat*}{3}\n")

printFooter = toLazyText (
  fromString "\\end{alignat*}\n"<>
  fromString "\\end{document}\n"
  )

main = do
  args <- getArgs
  case args of
    [] -> Prelude.putStrLn "Call with a number as argument."
    (n:_) -> do
        probs <- genProbs (read n) []
        putStr $ printHeader
        putStr $ showProblems probs
        putStr $ printFooter

