(ns front.components.control-panel
  (:require [front.components.logo :as logo]
            [front.components.spinner :as spinner]
            [front.router :refer [push!]]
            [re-frame.core :refer [subscribe]]))

(defn render-logo []
  [:div {:class "black dim pointer"
         :on-click #(push! :threads)}
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