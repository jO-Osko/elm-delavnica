module App exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Browser exposing (element)
import Html
import Html.Events as He


type Msg
    = Increase
    | Decrease


initialize () =
    ( 1, Cmd.none )


view model =
    Grid.container []
        [ Html.h1 []
            [ Html.text ("Hello world: " ++ String.fromInt model)
            ]
        , Button.button
            [   Button.success,
                Button.block
                , Button.attrs
                [ He.onClick Increase
                ]
            ]
            [ Html.text "Povečaj" ]
        , Button.button
            [   Button.danger,
                Button.block
                , Button.attrs
                [ He.onClick Decrease
                ]
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



-- elm-live src/App.elm --open -- --debug --output=dist/js/app.js
