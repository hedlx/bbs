(ns front.components.post
  (:require
   [front.components.image :as image]
   [front.components.link :as link]
   [front.router :refer [routes]]
   [front.util.js :refer [ts->iso]]))


(defn- render-header [id name trip ts show-link?]
  (let [res-name (if (nil? name) "Anonymous" name)]
    [:div {:class "post-header"}
     [:div {:class "post-header-item"}
      [:div {:class "post-header-item-number"} "#" id]]
     [:div {:class "post-header-item"}
      [:div {:class "post-header-item-name-container"}
       [:div {:class "post-header-item-name"} res-name]
       (when (not (nil? trip))
         [:div {:class "post-header-item-trip"} "!" trip])]]
     [:div {:class "post-header-item"}
      [:div (-> ts (* 1000) ts->iso)]]
     (when show-link?
       [:div {:class "post-header-item"}
        [:div
         "["
         [link/c {:href ((:thread @routes) {:id id})
                  :label "Reply"}]
         "]"]])]))

(defn c []
  (fn [{:keys [id
               name
               text
               trip
               ts
               media
               show-link?
               op?]}]
    [:div {:class (if op? "post post--full" "post")}
     (render-header id name trip ts show-link?)
     [:div {:class "post-content"}
      (if (empty? media)
        nil
        [:div {:class "post-image"} [image/c {:media media}]])
      text]]))
