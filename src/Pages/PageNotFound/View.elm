module Pages.PageNotFound.View exposing (view)

import Html exposing (div, h4, text, Html)


view : Html a
view =
    div []
        [ h4 []
            [ text "Page Not Found" ]
        ]
