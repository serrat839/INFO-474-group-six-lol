library(httr)
library(dplyr)
library(stringr)
library(jsonlite)

# join artist data to song data 
album_data <- read.csv("./clean_data/award_winner_ids.csv")
song_data <- read.csv("./clean_data/song_list.csv")

data <- left_join(song_data, album_data, by= c("album_ids" = "album_id"))

# I take back any praise I gave this api. it did not give me full data.
base_endpoint <- "https://api.musixmatch.com/ws/1.1/matcher.lyrics.get"
query_begin <- "?format=jsonp&callback=callback&q_track="
query_middle <- "&q_artist="
query_end <- "&apikey="
api_key <- ""

final_lyrics <- c()
final_artist <- c()
final_song <- c()
for (idx in 1:nrow(data)) {
  test_song_name <- data$track[idx]
  test_song_artist <- data$artist[idx]
  
  if (test_song_artist == "Tony Bennett" || test_song_artist == "Eric Clapton") {
    test_song_name <- str_split(test_song_name, " - ")[[1]][1]
  }
  print(paste0(test_song_name, " | ", test_song_artist))
  filtered_song_name <- str_replace_all(test_song_name, "\ ", "%20")
  filtered_song_artist <- str_replace_all(test_song_artist, "\ ", "%20")
  
  asdf <- GET(paste0(base_endpoint,
                     query_begin, filtered_song_name,
                     query_middle, filtered_song_artist,
                     query_end, api_key))
  
  req_content <- content(asdf)
  req_content <- str_sub(req_content, 10, -3)
  req_content <- fromJSON(req_content)
  lyrics <- "N/A"
  if (req_content$message$header$status_code == 200) {
    lyrics <- req_content$message$body$lyrics$lyrics_body
  }
  
  
  final_lyrics <- c(final_lyrics, lyrics)
  final_artist <- c(final_artist, test_song_artist)
  final_song <- c(final_song, data$track[idx])
}

lyric_data <- data.frame("lyrics"=final_lyrics,
                         "artist"=final_artist,
                         "song"=final_song, stringsAsFactors = F)
write.csv(lyric_data, "./clean_data/lyric_data.csv")

data2 <- left_join(data, lyric_data, by= c("artist" = "artist", "track" = "song"))

write.csv(lyric_data, "./clean_data/album_song_lyric_data.csv")
