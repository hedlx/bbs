(ns front.components.spinner-overlay
  (:require [front.components.spinner :as spinner]))


(defn c []
  (fn []
    [:div {:class "absolute absolute--fill flex items-center justify-center"}
     [:div {:class "w3 h3"}
      [spinner/c]]]))