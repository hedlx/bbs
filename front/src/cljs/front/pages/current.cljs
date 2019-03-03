(ns front.pages.current
  (:require
    [reagent.session :as session]
    [front.router :as router]))


(defn page []
  (fn []
    (let [page (:current-page (session/get :route))]
      [:div
        [:div {:class "fl w-100 pa2"}
          [:h1 {:class "f1 lh-title"} "hedlx board"]]
        [page]])))
