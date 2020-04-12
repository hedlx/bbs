(ns front.pages.current
  (:require
    [front.components.control-panel :as control-panel]
    [front.pages.thread :as thread]
    [front.pages.threads :as threads]
    [front.components.create-new :as create-new]
    [front.components.spinner-overlay :as spinner-overlay]
    ["@material-ui/core" :as mui]
    [re-frame.core :refer [subscribe]]))


(defn page-for [route]
  (case route
    :threads #'threads/page
    :thread #'thread/page
    :test #'create-new/c
    :undefined :div))

(defn- header-bar []
  (fn []
    (let [y       @(subscribe [:y-offset])
          delta   @(subscribe [:y-offset-delta])
          trigger (or (< y 100) (< delta 0))]
      [:> mui/Slide
        {:appear false
         :in trigger}
        [:> mui/AppBar
          [:> mui/Toolbar
            [:> mui/Typography
              {:variant "h6"}
              "BBS"]]]])))

(defn page []
  (fn []
    [:<>
      [header-bar]
      [:> mui/Toolbar]
      [:> mui/Container
        [:div {:class "current-page-content"}
          (if @(subscribe [:major-loading?])
            [spinner-overlay/c]
            [(page-for @(subscribe [:current-page]))])]]]))
