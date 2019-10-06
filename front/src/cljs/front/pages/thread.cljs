(ns front.pages.thread
  (:require
   [front.components.post :as post]
   [re-frame.core :refer [subscribe]]))

(defn- render-post [post]
  (let [id (:no post)
        op? (zero? id)]
    ^{:key id}
    [:div {:class (if op? "thread-post thread-post--full" "thread-post")}
     [post/c (assoc post :id id :op? op?)]]))

(defn- render-posts [posts]
  (map render-post posts))

(defn- render-content [posts error]
  (cond
    error [:div "ERROR"] ;TODO: you know
    :default (render-posts posts)))

(defn page []
  (fn []
    (let [subject @(subscribe [:thread-subject])
          posts @(subscribe [:thread-posts])
          error @(subscribe [:thread-error])]
      [:<>
       (when (-> subject nil? not)
         [:div {:class "thread-subject"} subject])
       [:div {:class "thread"}
        (render-content posts error)]])))
