module User exposing (User, decodeList, removeFromList)

import Dict
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, optionalAt, required)


type alias User =
    { userUid : Int
    , globalScore : Int
    , dayScores : Dict.Dict Int DayScore
    , fullScore : Int
    }


removeFromList : User -> List User -> List User
removeFromList user list =
    case list of
        [] ->
            []
        (x::xs) -> 
            if x.userUid == user.userUid then 
                removeFromList user xs
            else x :: removeFromList user xs

type alias FullResponse =
    { ownerId : String
    , members : List User
    }


type alias DayScore =
    { star1 : Maybe Int
    , star2 : Maybe Int
    }


type alias UserData =
    { userUid : String
    , globalScore : Int
    , dayScores : Dict.Dict String DayScore
    }


decodeList : Decoder (List User)
decodeList =
    Decode.map (\x -> x.members) decodeFullResponse


decodeFullResponse : Decoder FullResponse
decodeFullResponse =
    succeed FullResponse
        |> required "owner_id" Decode.string
        |> required "members"
            (Decode.andThen
                (\dict ->
                    List.filterMap
                        (\usr ->
                            let
                                scores =
                                    Dict.fromList (List.filterMap (\( k, v ) -> Maybe.map (\kInt -> ( kInt, v )) (String.toInt k)) <| Dict.toList usr.dayScores)

                                fullScore =
                                    Dict.foldl (\_ { star1, star2 } su -> su + (List.length <| List.filter ((/=) Nothing) [ star1, star2 ])) 0 scores
                            in
                            Maybe.map
                                (\uidInt ->
                                    { userUid = uidInt
                                    , globalScore = usr.globalScore
                                    , dayScores = scores
                                    , fullScore = fullScore
                                    }
                                )
                                (String.toInt usr.userUid)
                        )
                        (Dict.values dict)
                        |> succeed
                )
                (Decode.dict decodeUserData)
            )


decodeUserData : Decoder UserData
decodeUserData =
    succeed UserData
        |> required "id" Decode.string
        |> required "global_score" Decode.int
        |> required "completion_day_level" (Decode.dict decodeDayScore)


decodeDayScore : Decoder DayScore
decodeDayScore =
    succeed DayScore
        |> optionalAt [ "1", "get_star_ts" ] (Decode.andThen (succeed << String.toInt) Decode.string) Nothing
        |> optionalAt [ "2", "get_star_ts" ] (Decode.andThen (succeed << String.toInt) Decode.string) Nothing


decodeStringToInt =
    Decode.andThen (\x -> x)
