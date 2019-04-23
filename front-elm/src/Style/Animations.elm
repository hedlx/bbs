module Style.Animations exposing (css, fadein_l, fadein_r)

import Html exposing (Html, node, text)


css : Html msg
css =
    node "style"
        []
        [ text """
            @keyframes fadeInRight {
                from {
                    opacity: 0;
                    transform: translateX(15px);
                }

                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .fadeInRight {
                animation-duration: 0.3s;
                animation-name: fadeInRight;
            }

            @keyframes fadeInLeft {
                from {
                    opacity: 0;
                    transform: translateX(-15px);
                }

                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .fadeInLeft {
                animation-duration: 0.3s;
                animation-name: fadeInLeft;
            }
        """ ]


fadein_r : String
fadein_r =
    "fadeInRight"


fadein_l : String
fadein_l =
    "fadeInLeft"
