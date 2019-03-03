(ns front.pages.current
  (:require
    [front.router :refer [page-for]]
    [re-frame.core :refer [subscribe]]))

(defn page []
  (fn []
    [:div
      [:div {:class "fl w-100 pa2"}
        [:h1 {:class "f1 lh-title"} "hedlx board"]]
      [(page-for @(subscribe [:current-page]))]]))
