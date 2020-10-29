library(httr)
library(dplyr)
library(stringr)

client_id <-  ""
secret <- ""

r <- POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(client_id, secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

token <- content(r)$access_token
headerValue <- paste0("Bearer ", token)

# GET(url=url, add_headers(Authorization=headerValue))



# test the function to get the tracks spotify:album:2hjeKa2x3W9F8GwlqBKBWV
test_id <- "2hjeKa2x3W9F8GwlqBKBWV"

scrape_albums <- function(album_id, header_value) {
  
  base_endpoint <- "https://api.spotify.com/v1/albums/"
  finish_endpoint <- "/tracks"
  
  query <- paste0(base_endpoint, album_id, finish_endpoint)
  
  response <- GET(url=query, add_headers(Authorization=header_value))
  response <- content(response)
  
  songs <- response$items
  
  album_ids <- c()
  track <- c()
  track_id <- c()
  # preview_url <- c() NO IDEA why this will always return null when iterating through songs
  runtime <- c()
  for (song in songs) {
    album_ids <- c(album_ids, album_id)
    track <- c(track, song$name)
    track_id <- c(track_id, song$id)
    # preview_url <- c(preview_url, song[["preview_url"]])
    runtime <- c(runtime, song[["duration_ms"]])
  }
  
  end <- data.frame("album_ids" = album_ids,
                    "track" = track,
                    "track_id" = track_id,
                    # "preview_url" = preview_url,
                    "runtime" = runtime, stringsAsFactors = F)
  return(end)
}

data <- data.frame()
#read in dataframe with album info
award_winners <- read.csv("./clean_data/award_winner_ids.csv")

# get all song info
for (album in award_winners$album_id) {
  if(album != "N/A") {
    
    if (nrow(data) == 0) {
      data <- scrape_albums(album, headerValue)
    } else {
      data <- rbind(data, scrape_albums(album, headerValue))
    }
  }
}

# write out our data to clean data
write.csv(data, "./clean_data/song_list.csv")
