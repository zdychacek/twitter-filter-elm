module Tweet.Decoder exposing (decodeTweets)

import Json.Decode exposing (Decoder, (:=), andThen, at, decodeString, list, maybe, succeed, string, int)
import Json.Decode.Extra exposing ((|:))
import Tweet.Model exposing (Tweet)


decodeUrl : Decoder (Maybe String)
decodeUrl =
    at [ "entities", "media" ]
        (list ("media_url" := string))
        |> Json.Decode.map List.head


decodeTweetWithUrl : Maybe String -> Decoder Tweet
decodeTweetWithUrl url =
    case url of
        Nothing ->
            Json.Decode.fail "No image"

        Just url ->
            succeed Tweet
                |: ("id" := int)
                |: (succeed url)
                |: ("text" := string)


decodeTweet : Decoder (Maybe Tweet)
decodeTweet =
    maybe (decodeUrl `andThen` decodeTweetWithUrl)


filteredDecoder : Decoder (List (Maybe a)) -> Decoder (List a)
filteredDecoder decoder =
    Json.Decode.map (List.filterMap identity)
        decoder


decodeTweets : Decoder (List Tweet)
decodeTweets =
    at [ "statuses" ]
        (list decodeTweet)
        |> filteredDecoder
