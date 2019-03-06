(ns front.components.post
  (:require [front.router :refer [routes]]))


(defn c []
  (fn [{:keys [id name text show-link?]}]
      [:div {:class "flex flex-column min-w5 pa3 br2 bg-dark-pink ba b--pink"}
        [:div {:class "flex pb2"}
          [:div {:class "b pr2"} (if (nil? name) "Anonymous" name)]
          [:div {:class "pr2"}
           (if show-link?
             [:a {:href ((:thread @routes) {:id id})} id]
             id)]]
        [:div text]]))