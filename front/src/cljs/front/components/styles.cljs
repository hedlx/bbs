(ns front.components.styles
  (:require
    [front.styles.colors :as colors]
    [cljss.core :refer-macros [defstyles]]
    [clojure.string :as str]))


(defstyles input-class [font-size]
  {:width "100%"
   :height "27px"
   :padding-left "5px"
   :background-color colors/light-purple
   :border (str/join " " ["1px solid" colors/purple])
   :border-radius "2px"
   :outline 0
   :font-size font-size
   :color "#000000"

   "&::placeholder" {:color "#000000"
                     :opacity 0.5}

   :&:focus:enabled {:border (str/join " " ["1px solid" colors/light-purple])}

   :&:disabled {:cursor "default"
                :background (str/join " "
                                      ["repeating-linear-gradient("
                                       "45deg,"
                                       colors/light-purple ","
                                       colors/light-purple "10px,"
                                       colors/light-pink "10px,"
                                       colors/light-pink "20px" ")"])}})


(defstyles textarea-class [font-size]
  {:width "100%"
   :height "100%"
   :padding "5px"
   :background-color colors/light-purple
   :border (str/join " " ["1px solid" colors/purple])
   :border-radius "2px"
   :outline 0
   :font-size font-size
   :resize "none"
   :color "#000000"

   "&::placeholder" {:color "#000000"
                     :opacity 0.5}

   :&:focus:enabled {:border (str/join " " ["1px solid" colors/light-purple])}

   :&:disabled {:cursor "default"
                :background (str/join " "
                                      ["repeating-linear-gradient("
                                       "45deg,"
                                       colors/light-purple ","
                                       colors/light-purple "10px,"
                                       colors/light-pink "10px,"
                                       colors/light-pink "20px" ")"])}})

(defstyles primary-button-class [font-size]
  {:width "100%"
   :height "100%"
   :padding-left "10px"
   :padding-right "10px"
   :padding-top "5px"
   :padding-bottom "5px"
   :background-color colors/purple
   :border 0
   :border-radius "2px"
   :cursor "pointer"
   :color "#000000"

   :&:hover:enabled
   {:background-color colors/purple-0}

   :&:focus:enabled
   {:background-color colors/purple-0}

   :&:disabled {:cursor "default"
                :opacity "0.6"}})
