module Style.Animations exposing (css, fadein_left_ns, fadein_right, fadein_top_s)

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

            .fadein-right {
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

            @media screen and (min-width: 30em) {
                .fadein-left-ns {
                    animation-duration: 0.3s;
                    animation-name: fadeInLeft;
                }
            }

            @keyframes fadeInTop {
                from {
                    opacity: 0;
                    transform: translateY(-15px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            @media screen and (max-width: 30em) {
                .fadein-top-s {
                    animation-duration: 0.3s;
                    animation-name: fadeInTop;
                }
            }
        """ ]


fadein_right : String
fadein_right =
    "fadein-right"


fadein_left_ns : String
fadein_left_ns =
    "fadein-left-ns"


fadein_top_s : String
fadein_top_s =
    "fadein-top-s"
