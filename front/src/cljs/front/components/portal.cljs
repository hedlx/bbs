(ns front.components.portal
  (:require [reagent.core :as r]
            [cljss.core :refer-macros [defstyles]]
            [react-dom :as rdom]))


(defstyles portal-container-class []
  {:position "fixed"
   :left 0
   :right 0
   :top 0
   :bottom 0})

(defn c []
  (fn [& children]
    (rdom/createPortal
     (r/as-element
      [:div
       {:class (portal-container-class)}
       children])
     (js/document.getElementById "portal"))))
