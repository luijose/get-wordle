# get-wordle
**Simple Wordle solver bash script.**

## Parameters
  - $1  = Ignored Characters (ie. will exclude words that contain the characters listed).
  - $2* = Known Characters (ie. will require the character provided for each position). You can prepend ^ to exclude characters from any position.

## Notes
  - Script output is limited to top 5 matching words, sorted by the calculated score based on character popularity for each position.
  - If no params are provided, script will only output words with unique characters, in order to optimize towards more letter hits.
  - To use default values or ignore any param, you can use a "?" as the param value.
  - First time running will calculate word scores, and will take longer based on words list size, word size, and available CPU.
  - Why did I write this as a bash script? Idk...

## Examples
  - `./gw.sh`             -- Prints words that match the configured word_size.
  - `./gw.sh abc`         -- Prints words that exclude characters a, b and c in any position.
  - `./gw.sh ? d`         -- Prints words with letter 'd' in the first (left-most) position.
  - `./gw.sh abc d`       -- Prints #2, but only include words that start with letter 'd'.
  - `./gw.sh ? ^de ? ? a` -- Prints words with the letter 'a' in the 4th position (left-to-right) that do not start with the letter 'd' or 'e'.

## Requirements
  - Basic Linux utilities: bash, grep, awk, cut, sed, tr, sort, uniq, head

## Tested dictionaries (sorted ASC).
  - Google Top 10,000 words: https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english.txt
  - Wordle word list: https://raw.githubusercontent.com/Kinkelin/WordleCompetition/main/data/official/shuffled_real_wordles.txt
  - Oxford English Dictionary: https://raw.githubusercontent.com/sujithps/Dictionary/master/Oxford%20English%20Dictionary.txt
  - Extended Official Scrabble Player's Dictionary: https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt
  - Extended Wordle word list: https://raw.githubusercontent.com/Kinkelin/WordleCompetition/main/data/official/combined_wordlist.txt
  - Infochimps word list: https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt
