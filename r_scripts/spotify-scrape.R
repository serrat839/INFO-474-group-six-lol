library(httr)
library(dplyr)
library(stringr)

# DO not run this file or you will have to get the album IDS for the missing albums lol
# get ur own keys smgdh
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

# load in our song data
award_winners <-read.csv("grammy_album_clean.csv", stringsAsFactors = F)

# search for album ids
album_id_get <- function(album, artist, header_val) {
  # endpoint
  search_endpoint <- 	"https://api.spotify.com/v1/search?q="

  # constructing query
  search_album <- "album:"
  search_artist<- " artist:"
  search_type <- "&type=album"
  query <- paste0(search_album, album,search_artist, artist, search_type)

  to_replace <- c(":", "\ ", ",", "\\?",'"', "/")
  substitute <- c("%3A","%20", "%2c","%3f", "%22", "%2f")
  for (replacement in 1:length(to_replace)) {
    query <- str_replace_all(query, to_replace[replacement], substitute[replacement])
  }

  response <- GET(url=paste0(search_endpoint, query), add_headers(Authorization=header_val))
  response_content <- content(response)
  response_content <- response_content$albums$items
  if (length(response_content) == 0) {
    return("N/A")
  }

  return(response_content[[1]][["id"]])
}

album_ids <- c()
for (idx in 1:nrow(award_winners)) {
  album_ids <- c(album_ids, album_id_get(award_winners$album[idx], award_winners$artist[idx], headerValue))
}
award_winners$album_id <- album_ids

# write csv. Inspect for NA values.
write.csv(award_winners, "award_winner_ids.csv", row.names = F)
