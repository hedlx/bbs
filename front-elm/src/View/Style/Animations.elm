module View.Style.Animations exposing (css, fadein_r)

import Html exposing (node, text)


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


fadein_r =
    "fadeInRight"
