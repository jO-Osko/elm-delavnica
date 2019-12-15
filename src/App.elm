module App exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Browser exposing (element)
import Html
import Html.Attributes exposing (class, href, target)
import Html.Events as He
import Http
import User


type Msg
    = UserRefreshResponse (Result Http.Error (List User.User))
    | EditMsg User.User EditUserMsg


type EditUserMsg
    = Delete
    | Increase
    | Decrease


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
            , Grid.col [] [ Html.text "Urejanje" ]
            ]
         ]
            ++ (List.sortBy .fullScore model.users
                    |> List.reverse
                    |> List.map
                        (\usr ->
                            let
                                userMessage =
                                    EditMsg usr
                            in
                            Grid.row []
                                [ Grid.col [] [ Html.text (String.fromInt usr.userUid) ]
                                , Grid.col [] [ Html.text (String.fromInt usr.fullScore) ]
                                , Grid.col []
                                    [ Grid.row []
                                        [ Grid.col
                                            [ Col.attrs [ class "btn btn-success", He.onClick <| userMessage Increase ] ]
                                            [ Html.text "Povečaj" ]
                                        , Grid.col
                                            [ Col.attrs [ class "btn btn-warning", He.onClick <| userMessage Decrease ] ]
                                            [ Html.text "Zmanjšaj" ]
                                        , Grid.col
                                            [ Col.attrs [ class "btn btn-danger", He.onClick <| userMessage Delete ] ]
                                            [ Html.text "Izbriši" ]
                                        ]
                                    ]
                                ]
                        )
               )
        )


update msg model =
    case msg of
        UserRefreshResponse (Ok users) ->
            ( { model | users = users }, Cmd.none )

        EditMsg user editMsg ->
            let
                users =
                    case editMsg of
                        Delete ->
                            User.removeFromList user model.users

                        Increase ->
                            User.updateUser user (\usr -> { usr | fullScore = usr.fullScore + 1 }) model.users

                        Decrease ->
                            User.updateUser user (\usr -> { usr | fullScore = usr.fullScore - 1 }) model.users
            in
            ( { model | users = users }, Cmd.none )

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
