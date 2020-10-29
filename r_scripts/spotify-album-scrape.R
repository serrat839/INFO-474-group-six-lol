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