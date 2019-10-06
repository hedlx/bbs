(ns front.components.spinner-overlay
  (:require [front.components.spinner :as spinner]))


(defn c [{:keys [delay] :or {delay 0}}]
  [:div {:class "spinner-overlay"}
   [:div {:class "spinner-overlay-container"}
    [spinner/c {:delay delay}]]])
