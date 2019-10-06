(ns front.components.control-panel
  (:require [front.icons.logo :as logo]
            [front.icons.plus :as plus]
            [front.components.create-new :as create-new]
            [front.components.spinner :as spinner]
            [front.components.outside-click-listener :as outside-cl]
            [front.router :refer [push!]]
            [reagent.core :as r]
            [re-frame.core :refer [subscribe]]))


(def show-create-popup? (r/atom false))
(def add-ref (r/atom nil))

(defn- logo []
  [:div {:class "control-panel-control"
         :on-click #(push! :threads)}
   [logo/icon]])

(defn- add [show-popup?]
  [:div {:class "control-panel-add-container"}
   [:div {:class "control-panel-control"
          :ref #(reset! add-ref %)
          :on-click #(swap! show-create-popup? not)}
    [plus/icon]]
   (when show-popup?
     [outside-cl/c {:parent-ref add-ref
                    :on-click #(reset! show-create-popup? false)}
      [:div {:class "control-panel-popup-container"}
       [create-new/c {:on-success #(reset! show-create-popup? false)
                      :on-close #(reset! show-create-popup? false)}]]])])

(defn c []
  (fn []
    (let [show-loading? @(subscribe [:minor-loading?])]
      [:div {:class "control-panel"}
       (if show-loading?
         [:div {:class "control-panel-spinner-container"}
          [spinner/c]]
         [logo])
       [add @show-create-popup?]])))
