module Style.Animations exposing (css, fadein_r)

import Html exposing (Html, node, text)


css : Html msg
css =
    node "style"
        []
        [ text """
            @keyframes fadeInRight {
                from {
                    opacity: 0;
                    transform: translateX(50px);
                }

                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .fadeInRight {
                animation-duration: 0.5s;
                animation-name: fadeInRight;
            }
        """ ]


fadein_r : String
fadein_r =
    "fadeInRight"
