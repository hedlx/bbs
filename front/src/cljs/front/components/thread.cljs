(ns front.components.thread
  (:require [front.components.post :as post]
            [re-frame.core :refer [subscribe]]))


(defn- render-thread [thread]
  (let [{:keys [id op]} thread]
    ^{:key (:no op)}
    [post/c (assoc op
                   :id id
                   :op? true
                   :show-link? @(subscribe [:threads-page?]))]))

(defn- render-post [post]
  ^{:key (:no post)}
  [:div {:class "pt1 pl3"}
   [post/c (assoc post :id (:no post))]])

(defn c []
  (fn [{:keys [thread]}]
    [:div {:class "flex flex-column items-start"}
     (conj
       (map render-post (:last thread))
       (render-thread thread))]))