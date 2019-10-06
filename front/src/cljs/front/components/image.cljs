(ns front.components.image
  (:require [reagent.core :as r]
            [re-frame.core :refer [subscribe]]
            [front.util.url :refer [gen-url]]
            [front.components.portal :as portal]
            [front.components.spinner-overlay :as spinner-overlay]))

(defn- fullscreen []
  (let [idx-atom (r/atom 0)
        loading? (r/atom true)]
    (fn [{:keys [media on-close]}]
      (let [media-count (count media)
            nav? (> media-count 1)
            idx (mod @idx-atom media-count)
            inc-idx #(do (swap! idx-atom inc) (reset! loading? true))
            dec-idx #(do (swap! idx-atom dec) (reset! loading? true))
            w-width @(subscribe [:w-width])
            w-height @(subscribe [:w-height])
            floating-size (* (max w-height w-width) 0.1)
            item (nth media idx)
            src (gen-url @(subscribe [:base-url]) "i" (:id item))]
        [portal/c
         ^{:key "¯|_(ツ)_|¯"}
         [:div {:class "fullscreen"}
          (if @loading? [spinner-overlay/c {:delay 200}] nil)
          [:img {:style {:display (if @loading? "none" "block")
                         :max-width (str w-width "px")
                         :max-height (str w-height "px")}
                 :src src
                 :on-click (if nav? inc-idx #())
                 :on-load #(reset! loading? false)}]
          (if nav?
            [:div {:class "fullscreen-nav-container fullscreen-nav-container--left"}
             [:div {:class "fullscreen-nav"
                    :on-click inc-idx} "<"]])
          (if nav?
            [:div {:class "fullscreen-nav-container fullscreen-nav-container--right"}
             [:div {:class "fullscreen-nav"
                    :on-click dec-idx} ">"]])
          [:div {:class "fullscreen-close"
                 :on-click on-close}
           "X"]]]))))

(defn c []
  (let [full? (r/atom false)]
    (fn [{:keys [media]}]
      (let [id (-> media (first) (:id))
            src (gen-url @(subscribe [:base-url]) "t" id)
            media-count (count media)]
         [:div {:class "image"}
          [:img {:src src
                 :width "100%"
                 :on-click #(reset! full? true)}]
          (if (> media-count 1)
            [:div {:class "image-overlay"}
             (str "+" (- media-count 1))]
            nil)
          (if @full? [fullscreen {:media media
                                  :on-close #(reset! full? false)}])]))))