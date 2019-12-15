module App exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Browser exposing (element)
import Html
import Html.Attributes exposing (class, href, target)
import Html.Events as He
import Http
import User


type Msg
    = UserRefreshResponse (Result Http.Error (List User.User))


initialize () =
    ( initialModel
    , Http.get { url = "data/leaderboard.json", expect = Http.expectJson UserRefreshResponse User.decodeList }
    )


type alias Model =
    { users : List User.User
    }


initialModel =
    { users = []
    }


view : Model -> Html.Html Msg
view model =
    Grid.container []
        ([ Html.h1 []
            [ Html.text "Trenutno stanje: "
            ]
         , Grid.row [ Row.attrs [ class "font-weight-bold" ] ]
            [ Grid.col [] [ Html.text "Uporabniško ime" ]
            , Grid.col [] [ Html.text "Točke" ]
            ]
         ]
            ++ List.map
                (\usr ->
                    Grid.row []
                        [ Grid.col [] [ Html.text (String.fromInt usr.userUid) ]
                        , Grid.col [] [ Html.text (String.fromInt usr.fullScore) ]
                        ]
                )
                model.users
        )


update msg model =
    case msg of
        UserRefreshResponse (Ok users) -> ({model | users= users}, Cmd.none)
        _ -> 
            ( model, Cmd.none )


main =
    element
        { init = initialize
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- elm-live src/App.elm --start-page=index_dev.html --open -- --debug --output=dist/js/app.js
