(ns front.components.control-panel
  (:require [front.icons.logo :as logo]
            [front.icons.plus :as plus]
            [front.components.create-new :as create-new]
            [front.components.spinner :as spinner]
            [front.components.outside-click-listener :as outside-cl]
            [front.router :refer [push!]]
            [front.styles.colors :as colors]
            [reagent.core :as r]
            [cljss.core :refer-macros [defstyles]]
            [re-frame.core :refer [subscribe]]))



(defstyles root-class []
  {:display "grid"
   :grid-template-columns "1fr"
   :grid-template-rows "repeat(2, max-content)"
   :grid-row-gap "15px"
   :align-items "start"})

(defstyles spinner-class []
  {:width "38px"
   :height "38px"})

(defstyles control-class []
  {:color colors/light-purple
   :cursor "pointer"
   :&:hover {:opacity "0.5"}})

(defstyles add-container []
  {:position "relative"})

(defstyles popup-class []
           {:position "absolute"
            :left "100%"
            :top 0
            :width "500px"
            :height "600px"
            :padding "15px"
            :margin-left "10px"
            :z-index 9999
            :background-color colors/dark-purple
            :border-radius "4px"
            :box-shadow "0px 0px 40px 2px rgba(255,255,255,0.2)"})

(def show-create-popup? (r/atom false))
(def add-ref (r/atom nil))

(defn- render-logo []
  [:div {:class (control-class)
         :on-click #(push! :threads)}
   [logo/icon]])

(defn- render-add [show-popup?]
  [:div {:class (add-container)}
   [:div {:class (control-class)
          :ref #(reset! add-ref %)
          :on-click #(swap! show-create-popup? not)}
    [plus/icon]]
   (when show-popup?
     [outside-cl/c {:parent-ref add-ref
                    :on-click #(reset! show-create-popup? false)}
      [:div {:class (popup-class)}
       [create-new/c {:on-success #(reset! show-create-popup? false)}]]])])

(defn c []
  (fn []
    (let [threads-loading? @(subscribe [:threads-loading?])
          threads-empty? (empty? @(subscribe [:threads]))
          show-loading? (and threads-loading? (not threads-empty?))]
      [:div {:class (root-class)}
       (if show-loading?
         [:div {:class (spinner-class)}
          [spinner/c {:color colors/purple-1}]]
         (render-logo))
       (render-add @show-create-popup?)])))