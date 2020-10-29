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
award_winners <-read.csv("./unclean_data/grammy_album_clean.csv", stringsAsFactors = F)

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
  
  return(response_content)
}

album_ids <- c()
large_image <- c()
med_image <- c()
small_image <- c()

for (idx in 1:nrow(award_winners)) {
  album_data <- album_id_get(award_winners$album[idx], award_winners$artist[idx], headerValue)
  if (length(album_data) == 0) {
    album_ids <- c(album_ids, "N/A")
    large_image <- c(large_image, "N/A")
    med_image <- c(med_image, "N/A")
    small_image <- c(small_image, "N/A")  
  } else {
    album_data <- album_data[[1]]
    album_ids <- c(album_ids, album_data$id)
    large_image <- c(large_image, album_data$images[[1]]$url)
    med_image <- c(med_image, album_data$images[[2]]$url)
    small_image <- c(small_image, album_data$images[[3]]$url)
  }
}
award_winners$album_id <- album_ids
award_winners$large_image <- large_image
award_winners$med_image <- med_image
award_winners$small_image <- small_image

# write csv. Inspect for NA values.
write.csv(award_winners, "./unclean_data/award_winner_ids.csv", row.names = F)
