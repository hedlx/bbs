(ns front.components.thread
  (:require [front.components.post :as post]
            [re-frame.core :refer [subscribe]]
            [cljss.core :refer-macros [defstyles]]))


(defstyles post-class []
  {:padding-top "5px"
   :padding-left "20px"})

(defstyles root-class []
  {:display "flex"
   :flex-direction "column"
   :align-items "flex-start"})

(defn- render-thread [thread]
  (let [{:keys [id op]} thread]
    ^{:key (:no op)}
    [post/c (assoc op
                   :id id
                   :op? true
                   :show-link? @(subscribe [:threads-page?]))]))

(defn- render-post [post]
  ^{:key (:no post)}
  [:div {:class (post-class)}
   [post/c (assoc post :id (:no post))]])

(defn c []
  (fn [{:keys [thread]}]
    [:div {:class (root-class)}
     (conj
       (map render-post (:last thread))
       (render-thread thread))]))
