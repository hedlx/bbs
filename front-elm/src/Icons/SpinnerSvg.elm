module Icons.SpinnerSvg exposing (icon)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


icon : Float -> Float -> Int -> Html msg
icon svgScale speed count =
    let
        w =
            String.fromFloat svgScale

        h =
            String.fromFloat svgScale
    in
    svg [ width w, height h, fill "currentColor" ]
        [ g [ fill "none" ] <|
            List.map
                (\n -> elem svgScale (svgScale / 64.0) (toFloat n / toFloat count) speed)
                (List.range 0 count)
        ]


elem : Float -> Float -> Float -> Float -> Svg msg
elem svgScale size phaseShift speed =
    let
        ox =
            svgScale / 2.0

        oy =
            ox

        radius =
            svgScale / 4

        ex =
            String.fromFloat (ox + radius * (cos <| degrees (360 * phaseShift)))

        ey =
            String.fromFloat (oy + radius * (sin <| degrees (360 * phaseShift)))

        size_ =
            String.fromFloat size

        period =
            1.0 / abs speed

        phaseShift_ =
            if speed > 0 then
                period * phaseShift - 0.3

            else
                0.3 - period * phaseShift

        startTime =
            String.fromFloat phaseShift_ ++ "s"

        duration =
            String.fromFloat period ++ "s"
    in
    g [ transform <| String.concat [ "translate(", ex, ",", ey, ")" ] ]
        [ circle [ fill "currentColor", cx "0", cy "0", r size_, opacity "0.0" ]
            [ animateTransform
                [ attributeName "transform"
                , type_ "scale"
                , from "1"
                , to "5"
                , dur duration
                , repeatCount "indefinite"
                , begin startTime
                ]
                []
            , animate
                [ attributeName "opacity"
                , from "1"
                , to "-0.25"
                , dur duration
                , repeatCount "indefinite"
                , begin startTime
                ]
                []
            ]
        ]
