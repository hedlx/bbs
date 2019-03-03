(ns front.router
  (:require
    [reagent.core :as reagent]
    [reitit.frontend :as reitit]
    [clerk.core :as clerk]
    [accountant.core :as accountant]
    [re-frame.core :as rf]
    [front.pages.threads :as threads]))


(def router
  (reitit/router
    [["/" :threads]]))

(defn path-for [route & [params]]
  (if params
    (:path (reitit/match-by-name router route params))
    (:path (reitit/match-by-name router route))))

(defn page-for [route]
  (case route
    :threads #'threads/page
    :undefined :div))

(defn init-router! [] 
  (clerk/initialize!)
  (accountant/configure-navigation!
   {:nav-handler
    (fn [path]
      (let [match (reitit/match-by-path router path)
            current-page (:name (:data  match))
            route-params (:path-params match)]
        (reagent/after-render clerk/after-render!)
        (rf/dispatch
          [:change-location {:current-page current-page
                             :route-params route-params}])
        (clerk/navigate-page! path)))

    :path-exists?
    (fn [path]
      (boolean (reitit/match-by-path router path)))})
  (accountant/dispatch-current!))