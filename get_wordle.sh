#!/bin/bash
## Parameters
#   $1  = Ignored Characters (ie. will exclude words that contain the characters listed)
#   $2* = Known Characters (ie. will require the character provided for each position)
#         You can prepend ^ to exclude characters from any position

## Examples
#   ./gw.sh             -- Prints words that match the configured word_size.
#   ./gw.sh abc         -- Prints words that exclude characters a, b and c in any position.
#   ./gw.sh ? d         -- Prints words with letter 'd' in the first (left-most) position.
#   ./gw.sh abc d       -- Prints #2, but only include words that start with letter 'd'.
#   ./gw.sh ? ^de ? ? a -- Prints words with the letter 'a' in the 4th position (left-to-right) that do not start with the letter 'd' or 'e'.

## Sample Dictionaries (Uncomment 1):
# Google Top 10,000 words
#words_url='https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english.txt'

# Wordle word list
words_url='https://raw.githubusercontent.com/Kinkelin/WordleCompetition/main/data/official/shuffled_real_wordles.txt'

# Oxford English Dictionary
#words_url='https://raw.githubusercontent.com/sujithps/Dictionary/master/Oxford%20English%20Dictionary.txt'

# Extended Official Scrabble Player's Dictionary
#words_url='https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt'

# Extended Wordle word list
#words_url='https://raw.githubusercontent.com/Kinkelin/WordleCompetition/main/data/official/combined_wordlist.txt'

# Infochimps word list
#words_url='https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt'

# Other Configurations
words_file='words.txt'  # Words dictionary file; relative path will be "enforced".
words_size=5            # Filter dictionary for words this size (Wordle = 5)

# Download Words file from URL provided if it doesn't already exist.
if [ ! -f "./$words_file" ]; then
  curl_return_code=0
  curl_output=`curl -w httpcode=%{http_code} -s "$words_url" -o "./$words_file" 2>/dev/null` || curl_return_code=$?;
  curl_http_code=$(echo ${curl_output} | sed -e 's/.*\httpcode=//')
  if [ $curl_return_code -ne 0 ] || [ $curl_http_code -ne 200 ]; then
    echo "ERROR: Could not fetch Words URL; Curl failed with error code $curl_return_code/$curl_http_code."
    rm -f $words_file
    exit
  fi
fi

# Get words of configured size from Words dictionary file.
words=`cat ./$words_file | awk '{ print $1 }' | tr -d "\r" | tr '[:upper:]' '[:lower:]' | grep -E "^[a-z]{$words_size}$" | sort -u`

# Get character popularity by position for filtered words list.
declare -A letters_score
count=1
while [ "$count" -le $words_size ]; do
  char_count=`echo -e "$words" | cut -c $count | sort | uniq -c | sort -n`
  while IFS= read -r line; do
    read -r score letter <<< $line
    letters_score[$count,"$letter"]=$score
  done <<< "$char_count"
  count=$((count+1))
done

# Get word score for filtered words list, if it doesn't already exist.
if [ ! -f "./scored_$words_file" ]; then
  while read word; do
    word_score=0
    count=1
    while [ $count -le $words_size ]; do
      letter=${word:$count-1:1}
      word_score=$((word_score+letters_score[$count,"$letter"]))
      count=$((count+1))
    done
    scored_words+="$word_score $word"$'\n'
  done <<< $words
  echo -e "$scored_words" | sort -nr > "./scored_$words_file"
fi

# Get Ignored Characters from CLI param #1.
if [ -n "$1" -a "$1" != "?" ]; then ignored_chars="$1"; else ignored_chars="!"; fi

# Get Known/Required Characters from CLI params #2*.
for (( num_arg=2; num_arg<=$((words_size+1)); num_arg++ )); do
  arg_val=${!num_arg}
  if [ -n "$arg_val" -a "$arg_val" != "?" ]; then
    known[$((num_arg-1))]="$arg_val";
    required_chars+=`echo "$arg_val" | tr -d '^' | sed 's/.\{1\}/\/&\/!d;/g'`
  else known[$((num_arg-1))]="a-z"; fi
  known_chars+="[${known[$((num_arg-1))]}]"
done

# Get matching words list, excluding ignored characters and including/excluding known characters.
words_list=`cat ./scored_$words_file | grep -vE "[$ignored_chars]" | grep -P "^\d+ $known_chars$" | sed "$required_chars"`

# Only include words with unique letters if no parameters are given.
if [ -z $1 ]; then words_list=`echo -e "$words_list" | grep -P '^\d+ (?:([a-z])(?!.*\1))*$'`; fi

# Print top 5 words.
echo -e "$words_list" | head -n 5
