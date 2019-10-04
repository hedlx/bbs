(ns front.components.spinner
  (:require
   [reagent.core :as r]
   [cljss.core :refer-macros [defstyles defkeyframes]]
   [clojure.string :as str]))


(defkeyframes rotate []
  {"100%" {:transform "rotate(360deg)"}})

(defkeyframes bounce []
  {"0%" {:transform "scale(0.0)"}
   "50%" {:transform "scale(1.0)"}
   "100%" {:transform "scale(0.0)"}})

(defstyles spinner-class []
  {:position "relative"
   :width "100%"
   :height "100%"
   :animation (str/join " " [(rotate) "2s infinite linear"])})

(defstyles dot-class [color]
  {:width "60%"
   :height "60%"
   :display "inline-block"
   :position "absolute"
   :top 0
   :border-radius "100%"
   :background-color color
   :animation (str/join " " [(bounce) "2s infinite ease-in-out"])})

(defstyles dot-delayed-class []
  {:top "auto"
   :bottom 0
   :animation-delay "-1s"})

(defn c []
  (let [show? (r/atom false)]
    (fn [{:keys [color delay] :or {delay 0}}]
      (r/create-class
       {:display-name "spinner"

        :component-did-mount
        (fn []
          (js/setTimeout #(reset! show? true) delay))

        :reagent-render
        (fn []
          (if @show?
            [:div {:class (spinner-class)}
             [:div {:class (dot-class color)}]
             [:div {:class (str/join " " [(dot-class color) (dot-delayed-class)])}]]
            nil))}))))