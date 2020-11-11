library(tidytext)
library(stringr)
library(dplyr)

song_data <- read.csv(paste0("./clean_data/album_song_lyric_data.csv"))

lyrics <- song_data %>% 
  select(album_ids, album, artist, track_id, lyrics)

lyric_tokens <- lyrics %>% 
  unnest_tokens(word, lyrics)

data(stop_words)

write.csv(stop_words, "./clean_data/stop_words.csv")


# join the sentiment sets

bing_add <- lyric_tokens %>% 
  left_join(get_sentiments("bing")) %>% 
  rename(bing_sentiment = sentiment)

afinn_add <- bing_add %>% 
  left_join(get_sentiments("afinn")) %>% 
  rename(bing_value = value)

nrc_add <- afinn_add %>% 
  left_join(get_sentiments("nrc")) %>% 
  rename(nrc_sentiment = sentiment)

write.csv(nrc_add, "./clean_data/lyric_token_sentiment.csv")
