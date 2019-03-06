(ns front.pages.thread
  (:require
    [front.components.post :as post]
    [front.components.spinner-overlay :as spinner-overlay]
    [re-frame.core :refer [subscribe]]))


(defn- render-post [post]
  ^{:key (:no post)}
  [:div {:class "pa1"}
   [post/c (assoc post :id (:no post))]])

(defn- render-posts [posts]
  (map render-post posts))

(defn- render-content [posts loading? error]
  (cond
    (and (empty? posts) loading?) [spinner-overlay/c]
    error    [:div "ERROR"] ;TODO: you know
    :default (render-posts posts)))

(defn page []
  (fn []
    (let [posts @(subscribe [:thread-posts])
          loading? @(subscribe [:thread-loading?])
          error @(subscribe [:thread-error])]
      [:div {:class "relative flex flex-column items-start w-100 h-100"}
       (render-content posts loading? error)])))