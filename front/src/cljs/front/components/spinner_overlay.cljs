(ns front.components.spinner-overlay
  (:require [front.components.spinner :as spinner]
            [cljss.core :refer-macros [defstyles]]))


(defstyles root-class [opacity]
  {:position "absolute"
   :top 0
   :bottom 0
   :left 0
   :right 0
   :display "flex"
   :flex-direction "column"
   :align-items "center"
   :justify-content "center"

   :background-color "#000"
   :opacity opacity})

(defstyles msg-container-class []
  {:padding-top "10px"})


(defstyles spinner-container-class []
  {:width "50px"
   :height "50px"})

(defn c [{:keys [color opacity msg] :or {opacity 0}}]
  [:div {:class (root-class opacity)}
   [:div {:class (spinner-container-class)}
    [spinner/c {:color color}]]
   (when (-> msg nil? not)
     [:div {:class (msg-container-class)} msg])])