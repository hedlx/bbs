(ns front.components.control-panel
  (:require [front.components.logo :as logo]
            [front.components.spinner :as spinner]
            [front.router :refer [routes]]
            [re-frame.core :refer [subscribe]]
            [secretary.core :as secretary]))

(defn render-logo []
  [:div {:class "black dim pointer"
         :on-click #(secretary/dispatch! ((:threads @routes)))}
   [logo/c]])

(defn c []
  (fn []
    (let [threads-loading? @(subscribe [:threads-loading?])
          threads-empty? (empty? @(subscribe [:threads]))
          show-loading? (and threads-loading? (not threads-empty?))]
      [:div {:class "flex flex-column"}
       (if show-loading?
         [:div {:class "w2 h2 mt2"} [spinner/c]]
         (render-logo))])))