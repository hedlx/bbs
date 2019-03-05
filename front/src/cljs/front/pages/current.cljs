(ns front.pages.current
  (:require
    [re-frame.core :refer [subscribe]]
    [front.router :refer [page-for]]
    [front.components.control-panel :as control-panel]))


(defn page []
  (fn []
    [:div {:class "fixed top-0 bottom-0 left-0 right-0"}
     [:div {:class "w-100 h-100 flex items-stretch bg-hot-pink black"}
      [:div {:class "flex justify-center w3 pa2"}
       [control-panel/c]]
      [:div {:class "w-100 h-100 overflow-y-auto"}
       [(page-for @(subscribe [:current-page]))]]]]))
