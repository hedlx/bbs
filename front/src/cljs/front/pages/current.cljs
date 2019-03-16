(ns front.pages.current
  (:require
    [front.components.control-panel :as control-panel]
    [front.pages.thread :as thread]
    [front.pages.threads :as threads]
    [front.components.create-new :as create-new]
    [front.styles.colors :as colors]
    [re-frame.core :refer [subscribe]]
    [cljss.core :refer-macros [defstyles]]))


(defstyles root-class []
  {:position "fixed"
   :top 0
   :bottom 0
   :left 0
   :right 0})

(defstyles container-class []
  {:display "flex"
   :align-items "stretch"
   :width "100%"
   :height "100%"
   :background-color colors/dark-purple
   :color colors/light-purple})

(defstyles left-panel-class []
  {:display "flex"
   :flex-shrink 0
   :justify-content "center"
   :padding "15px 10px 15px 10px"
   :width "60px"})

(defstyles content-class []
  {:width "100%"
   :height "100%"
   :padding-top "15px"
   :padding-right "15px"
   :overflow-y "auto"})

(defn page-for [route]
  (case route
    :threads #'threads/page
    :thread #'thread/page
    :test #'create-new/c
    :undefined :div))

(defn page []
  (fn []
    [:div {:class (root-class)}
     [:div {:class (container-class)}
      [:div {:class (left-panel-class)}
       [control-panel/c]]
      [:div {:class (content-class)}
       [(page-for @(subscribe [:current-page]))]]]]))
