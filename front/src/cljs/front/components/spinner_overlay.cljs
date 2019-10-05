(ns front.components.spinner-overlay
  (:require [front.components.spinner :as spinner]
            [cljss.core :refer-macros [defstyles]]))


(defstyles root-class []
  {:position "absolute"
   :top 0
   :bottom 0
   :left 0
   :right 0
   :display "flex"
   :flex-direction "column"
   :align-items "center"
   :justify-content "center"})

(defstyles spinner-container-class []
  {:width "50px"
   :height "50px"})

(defn c [{:keys [color delay] :or {delay 0}}]
  [:div {:class (root-class)}
   [:div {:class (spinner-container-class)}
    [spinner/c {:color color
                :delay delay}]]])
