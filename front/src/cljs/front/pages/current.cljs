(ns front.pages.current
  (:require
    [front.components.control-panel :as control-panel]
    [front.pages.thread :as thread]
    [front.pages.threads :as threads]
    [front.components.create-new :as create-new]
    [front.components.spinner-overlay :as spinner-overlay]
    [re-frame.core :refer [subscribe]]))


(defn page-for [route]
  (case route
    :threads #'threads/page
    :thread #'thread/page
    :test #'create-new/c
    :undefined :div))

(defn page []
  (fn []
    [:div {:class "current-page"}
     [:div {:class "current-page-container"}
      [:div {:class "current-page-left-panel"}
       [control-panel/c]]
      [:div {:class "current-page-content"}
       (if @(subscribe [:major-loading?])
         [spinner-overlay/c]
         [(page-for @(subscribe [:current-page]))])]]]))
