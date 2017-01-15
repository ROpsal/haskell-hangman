{--
 -- Author: Richard B. Opsal, PhD
 --  Start: 2013/12/22
 -- Update: 2014/11/21
 --
 -- Hangman console program as a Haskell exercise.
 --}

import Data.Char
import System.Random (randomRIO)
import System.Environment (getArgs)
import System.IO (hFlush, stdout)

-- Generate list of possible words from passed file.
-- One word per line in file.
wordList :: String -> IO [String]
wordList fn = do
        s <- readFile fn
        return $ map (map toUpper) $ lines s

-- Random item from passed, non-empty, list.
randomWord :: [a] -> IO a
randomWord xs = randomRIO (0, length xs - 1) >>= return . (xs !!)

-- Join the list of characters together with a space in-between.
wordJoin :: [Char] -> [Char]
wordJoin [x] = [x]
wordJoin (x:xs) = x : ' ' : wordJoin xs

-- The possible guess letters for Hangman.
alphaSet :: [Char]
alphaSet = ['A'..'Z']

-- Maximum guess count for Hangman.
maxGuesses :: Int
maxGuesses = 6

-- Generate a new guess list based on letter, current matches, and actual word.
applyGuess :: Char -> [Char] -> [Char] -> [Char]
applyGuess letter guesslist hanglist = zipWith (match) guesslist hanglist
    where match a b = if (b == letter) then b else a

-- Generate a new guess set based on letter, current set, and actual word.
applyGuess' :: Char -> [Char] -> [Char] -> [Char]
applyGuess' letter guess_set hanglist
    | not $ elem letter alphaSet  = guess_set
    |       elem letter guess_set = guess_set
    | not $ elem letter hanglist  = letter : guess_set
    |                  otherwise  = guess_set

-- Pad left side of string with spaces.
padLeft :: Int -> [Char] -> [Char]
padLeft width text = if (width <= length text) then text
                     else padLeft width $ ' ' : text

-- Output message for wins and losses.
formatSummary :: Show a => String -> a -> a -> IO ()
formatSummary message wins losses = do
    putStr   $ message ++ "  "
    putStr   $ "Wins : "   ++ (padLeft 2 $ show wins) ++ " "
    putStrLn $ "Losses : " ++ (padLeft 2 $ show losses)

-- Output message for new letter.
formatInput :: String -> Int -> IO ()
formatInput message count = do
    putStr $ "  " ++ message ++ "  "
    putStr $ "[Guesses left : " ++ (padLeft 2 $ show count) ++ " ] "
    putStr $ "Letter : "
    hFlush stdout           -- Force putStr characters to display!

-- Output Hangman word.
formatWord :: String -> IO ()
formatWord hanglist = do
    putStrLn $ "  " ++ wordJoin(hanglist) ++ "\n"


-- Hangman game actions.
data Action = NewGame | Exit deriving (Eq, Enum)
data Result = Win | Loss | Quit deriving (Eq, Enum)


{--
 -- Play a single round (one-word) of Hangman.
 --}

playRound :: String -> String -> String -> IO (Action, Result)
playRound hanglist guesslist guess_set = do

    if (hanglist == guesslist) then do
        formatWord hanglist
        return (NewGame, Win)

    else if (maxGuesses <= length guess_set) then do
        formatWord hanglist
        return (NewGame, Loss)

    else do

        formatInput (wordJoin guesslist) (maxGuesses - length guess_set)
        guess' <- getLine
        let guess = map (toUpper) guess'

        let exitResult = if (0 == length guess_set) then Quit else Loss
        case guess of
            []     -> playRound hanglist guesslist guess_set
            "EXIT" -> formatWord hanglist >> return (Exit, exitResult)
            "NEW"  -> formatWord hanglist >> return (NewGame, Loss)

            otherwise -> playRound hanglist new_guesslist new_guess_set
                where
                    new_guesslist = applyGuess  (head guess) guesslist hanglist
                    new_guess_set = applyGuess' (head guess) guess_set hanglist


{--
 -- Play the game of Hangman.
 --}

playGame :: Int -> Int -> [String] -> IO ()
playGame wins losses words = do

    -- Directions for playing the game.
    putStrLn "Type 'Exit' to leave the game, 'New' for a new game."
    putStrLn "Good luck!\n"

    -- Random word and other items for this round of Hangman.
    hanglist <- randomWord words
    let guesslist = take (length hanglist) (repeat '_')
    let guessset  = []::[Char]

    -- Play a single round (one-word) of Hangman.
    (action, result) <- playRound hanglist guesslist guessset
    let new_wins   = if (Win  == result) then wins   + 1 else wins
    let new_losses = if (Loss == result) then losses + 1 else losses
    let new_words  = filter (/= hanglist) words

    if (Win == result) then
        do formatSummary "Congratulations on your win!" new_wins new_losses

    else if (Loss == result) then
        do formatSummary "Too Bad!  Please try again." new_wins new_losses

    else do putStr ""

    case action of
        NewGame -> playGame new_wins new_losses new_words
        Exit    -> formatSummary "Thank you for playing Haskell Hangman!" new_wins new_losses


{--
 -- The Hangman application.
 --}

main = do

    -- Cheery intro to the Hangman game.
    putStrLn "Welcome to the Hangman word guessing game."

    -- List of words to guess from.
    myargs <- getArgs
    let fname = if null myargs then "dictionaryWords.txt" else head myargs
    words <- wordList fname

    -- Invoke the Hangman game.
    playGame 0 0 words


{--
 -- Building the application:
 --
 --		ghc -o Hangman Hangman.hs
 --}