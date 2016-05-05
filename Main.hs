{-# LANGUAGE OverloadedStrings, RecordWildCards, ScopedTypeVariables #-} 
module Main where
import Data.Time.Calendar
import Data.Time.Format
import Options.Applicative
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.Text (Text)
import Safe
import Control.Monad

data Options = Options {
    splitOnDelimiter :: Text -> [Text]
  , parseFormat :: String
  , parseFormatRef :: String
  , fieldNo :: Int
  , comparison :: Day -> Day -> Bool
  , refDate :: String
  , verbose :: Bool
  }

options = Options
  <$> (parseDelimiter 
      <$> strOption 
        ( short 'F'
        <> metavar "DELIMITER"
        <> help "Input delimiter. Default whitespace"
        <> value " "))
  <*> strOption 
      ( short 'i'
     <> metavar "FMT"
     <> help "Input date parse format. Default %Y-%m-%d"
     <> value "%Y-%m-%d" )
  <*> strOption 
      ( short 'r'
     <> metavar "FMT"
     <> help "Ref date parse format. Default %Y-%m-%d"
     <> value "%Y-%m-%d" )
  <*> argument auto 
      ( metavar "FIELD"
      <> help "Field position. Starts at 1. Default 1"
      <> value 1)
  <*> (parseOp <$> 
        strArgument
          ( metavar "COMPARISION-OP"
          <> help "=, >, <, >=, OR <=. Default >="
          <> value ">="
          ))
  <*> strArgument 
      ( metavar "REFDATE"
      <> help "Reference date for comparison. Parsed with ref date fmt" )
  <*> flag False True 
      ( short 'v'
      <> help "Verbose logging")

parseDelimiter :: String -> Text -> [Text]
parseDelimiter " " = T.words
parseDelimiter d = T.splitOn (T.pack d)

parseOp :: String -> (Day -> Day -> Bool)
parseOp s = 
    case s of
      "=" -> (==)
      ">" -> (>)
      "<" -> (<)
      ">=" -> (>=)
      "<=" -> (<=)
      x -> (==)

opts = info (helper <*> options)
            (fullDesc <> header "datefilter"
            <> progDesc "filters DSV input by reference date"
            <> footer "See http://hackage.haskell.org/package/time-1.5.0.1/docs/Data-Time-Format.html for format codes")

main :: IO ()
main = do
  Options{..} <- execParser opts
  xs <- T.lines <$> T.getContents
  let refDate' :: Day
      refDate' = maybe (error $ "Can't parse refDate: " ++ show refDate) 
                       id $ parseTimeM True defaultTimeLocale parseFormatRef refDate 
  xs' <- filterM (\line -> do
         let v :: Text
             v = at (splitOnDelimiter line) (fieldNo - 1)
         debug verbose $ "Field value: " ++ show v
         let d :: Maybe Day
             d = parseTimeM True defaultTimeLocale parseFormat . T.unpack $ v
         debug verbose $ "Parsed field date: " ++ show d
         let r :: Maybe Bool
             r = d >>= return . (flip comparison refDate')
         debug verbose $ "Comparision result: " ++ show r

         return $ (Just True) == r
        ) xs
  mapM_ T.putStrLn xs'

debug :: Bool -> String -> IO ()
debug False _ = return ()
debug True s = putStrLn $ "Log: " ++ s
