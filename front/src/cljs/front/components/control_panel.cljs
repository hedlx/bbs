(ns front.components.control-panel
  (:require [secretary.core :as secretary]
            [front.components.logo :as logo]
            [front.router :refer [routes]]))


(defn c []
  (fn []
    [:div {:class "flex flex-column"}
     [:div {:class "black dim pointer"
            :on-click #(secretary/dispatch! ((:threads @routes)))}
      [logo/c]]]))