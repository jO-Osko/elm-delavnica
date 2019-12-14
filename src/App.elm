module App exposing (main)

import Browser exposing (element)
import Html
import Html.Events as He


type Msg
    = Increase
    | Decrease


initialize () =
    ( 1, Cmd.none )


view model =
    Html.div []
        [ Html.div []
            [ Html.text ("Hello world: " ++ String.fromInt model)
            ]
        , Html.button
            [ He.onClick Increase
            ]
            [ Html.text "Povečaj" ]
        , Html.button
            [ He.onClick Decrease
            ]
            [ Html.text "Zmanjšaj" ]
        ]


update msg model =
    case msg of
        Increase ->
            ( model + 1, Cmd.none )

        Decrease ->
            ( model - 1, Cmd.none )


main =
    element
        { init = initialize
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- elm-live src/App.elm --open -- --debug
