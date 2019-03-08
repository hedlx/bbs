(ns front.components.post
  (:require [front.router :refer [routes]]
            [front.util.js :refer [ts->iso]]
            [clojure.string :as str]))


(defn- root-class [op?]
  (str/join " "
            ["flex"
             "flex-column"
             (if op? "w-100" "min-w5")
             "pa3"
             "br2"
             "bg-dark-pink"
             "ba"
             "b--pink"]))

(defn- render-header [id name trip ts show-link?]
  (let [res-name (if (nil? name) "Anonymous" name)]
    [:div {:class "flex pb2 code f6"}
     [:div {:class "fw5"} "#" id]
     [:div {:class "flex pl2"} res-name
      (when (not (nil? trip))
        [:div {:class "navy"} "!" trip])]
     [:div {:class "pl2"} (-> ts (* 1000) ts->iso)]
     (when show-link?
       [:div {:class "flex pl2"}
        "["
        [:a {:class "lightest-blue hover-lightest-blue dim"
             :href ((:thread @routes) {:id id})}
         "Reply"]
        "]"])]))

(defn c []
  (fn [{:keys [id
               name
               text
               trip
               ts
               show-link?
               op?]}]
    [:div {:class (root-class op?)}
      (render-header id name trip ts show-link?)
      [:div text]]))