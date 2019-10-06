(ns front.components.portal
  (:require [reagent.core :as r]
            [react-dom :as rdom]))


(defn c []
  (fn [& children]
    (rdom/createPortal
     (r/as-element
      [:div
       {:class "portal-container"}
       children])
     (js/document.getElementById "portal"))))
