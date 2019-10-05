(ns front.components.control-panel
  (:require [front.icons.logo :as logo]
            [front.icons.plus :as plus]
            [front.components.create-new :as create-new]
            [front.components.spinner :as spinner]
            [front.components.outside-click-listener :as outside-cl]
            [front.router :refer [push!]]
            [front.styles.colors :as colors]
            [reagent.core :as r]
            [cljss.core :refer-macros [defstyles] :as css]
            [re-frame.core :refer [subscribe]]))



(defstyles root-class []
  {:display "grid"
   :grid-template-columns "auto"
   :grid-template-rows "repeat(2, 38px)"
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
           {:padding "15px"
            :z-index 9999
            :background-color colors/dark-purple
            ::css/media {[[:max-width "900px"]]
                         {:position "fixed"
                          :left 0
                          :right 0
                          :top 0
                          :bottom 0}
                         [[:min-width "900px"]]
                         {:position "absolute"
                          :left "100%"
                          :top 0
                          :width "500px"
                          :height "600px"
                          :margin-left "10px"
                          :border-radius "4px"
                          :box-shadow "0px 0px 40px 2px rgba(255,255,255,0.2)"}}})

(def show-create-popup? (r/atom false))
(def add-ref (r/atom nil))

(defn- logo []
  [:div {:class (control-class)
         :on-click #(push! :threads)}
   [logo/icon]])

(defn- add [show-popup?]
  [:div {:class (add-container)}
   [:div {:class (control-class)
          :ref #(reset! add-ref %)
          :on-click #(swap! show-create-popup? not)}
    [plus/icon]]
   (when show-popup?
     [outside-cl/c {:parent-ref add-ref
                    :on-click #(reset! show-create-popup? false)}
      [:div {:class (popup-class)}
       [create-new/c {:on-success #(reset! show-create-popup? false)
                      :on-close #(reset! show-create-popup? false)}]]])])

(defn c []
  (fn []
    (let [show-loading? @(subscribe [:minor-loading?])]
      [:div {:class (root-class)}
       (if show-loading?
         [:div {:class (spinner-class)}
          [spinner/c {:color colors/purple-1}]]
         [logo])
       [add @show-create-popup?]])))
