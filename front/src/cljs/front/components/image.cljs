(ns front.components.image
  (:require [reagent.core :as r]
            [re-frame.core :refer [subscribe]]
            [front.util.url :refer [gen-url]]
            [cljss.core :refer-macros [defstyles]]
            [front.components.portal :as portal]
            [front.components.spinner-overlay :as spinner-overlay]
            [front.styles.colors :as colors]))


(defstyles fs-container-class []
  {:display "flex"
   :justify-content "center"
   :align-items "center"
   :width "100%"
   :height "100%"
   :background-color "rgba(0, 0, 0, 0.5)"})

(defstyles fs-image-class [loading? width height]
  {:display (if loading? "none" "block")
   :max-height (str (* height 0.95) "px")
   :max-width (str (* width 0.95) "px")})

(defstyles fs-nav-class [size left?]
    {:position "absolute"
     :top "0"
     :bottom "0"
     :left (if left? "0" "unset")
     :right (if left? "unset" "0")
     :display "flex"
     :justify-content "center"
     :align-items "center"
     :width (str size "px")
     :height "100%"
     :background-color "rgba(255, 255, 255, 0.4)"
     :font-size "42px"
     :font-weight "500"
     :opacity "0"
     :cursor "pointer"

     :&:hover {:opacity "1"}})

(defstyles close-class [size]
  {:position "absolute"
   :top "0"
   :right "0"
   :display "flex"
   :justify-content "center"
   :align-items "center"
   :width (str size "px")
   :height (str size "px")
   :background-color "rgba(255, 255, 255, 0.4)"
   :font-size "42px"
   :font-weight "500"
   :cursor "pointer"})

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
         ^{:key "¯|_(ツ)_|¯"} [:div {:class (fs-container-class)}
                              (if @loading? [spinner-overlay/c {:color colors/purple-1 :delay 200}] nil)
                              [:img {:class (fs-image-class @loading? w-width w-height)
                                     :src src
                                     :on-click (if nav? inc-idx #())
                                     :on-load #(reset! loading? false)}]
                              (if nav?
                                [:div {:class (fs-nav-class floating-size true)
                                       :on-click inc-idx}
                                 "<"])
                              (if nav?
                                [:div {:class (fs-nav-class floating-size false)
                                       :on-click dec-idx}
                                 ">"])
                              [:div {:class (close-class floating-size)
                                     :on-click on-close}
                               "X"]]]))))

(defstyles root-class []
  {:position "relative"
   :cursor "pointer"})

(defstyles overlay-container-class []
  {:position "absolute"
   :left 0
   :right 0
   :top 0
   :bottom 0
   :display "flex"
   :justify-content "center"
   :align-items "center"
   :background-color "rgba(0, 0, 0, 0.5)"
   :color "#fff"
   :opacity "0"
   :font-size "34px"
   :font-weight "500"

   :&:hover {:opacity "1"}})

(defstyles overlay-content-class []
  {:pointer-events "none"})

(defn c []
  (let [full? (r/atom false)]
    (fn [{:keys [media]}]
      (let [id (-> media (first) (:id))
            src (gen-url @(subscribe [:base-url]) "t" id)
            media-count (count media)]
         [:div {:class (root-class)}
          [:img {:src src
                 :width "100%"}]
          [:div {:class (overlay-container-class)
                 :on-click #(reset! full? true)}
           [:div {:class (overlay-content-class)}
            (if (> media-count 1) (str "+" (- media-count 1)) "Zoom")]]
          (if @full? [fullscreen {:media media
                                  :on-close #(reset! full? false)}])]))))