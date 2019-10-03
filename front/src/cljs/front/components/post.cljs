(ns front.components.post
  (:require
   [front.components.link :as link]
   [front.router :refer [routes]]
   [front.util.js :refer [ts->iso]]
   [front.styles.colors :as colors]
   [cljss.core :refer-macros [defstyles]]))


(defstyles root-class [width]
  {:min-width width
   :padding "10px"
   :border-radius "4px"
   :background-color colors/dark-yellow})

(defstyles header-class []
  {:display "flex"
   :flex-wrap "wrap"
   :padding-bottom "10px"
   :font-size "11px"
   :font-family "monospace"})

(defstyles header-item-class []
  {:padding-right "8px"
   :&:last-child {:padding-right 0}})

(defstyles header-item-number-class []
  {:font-weight 500})

(defstyles header-item-name-container-class []
  {:display "flex"
   :flex-wrap "wrap"})

(defstyles header-item-name-class []
  {:max-width "150px"
   :white-space "nowrap"
   :overflow "hidden"
   :text-overflow "ellipsis"})

(defstyles header-item-trip-class []
  {:display "inline-flex"
   :color colors/green-1})

(defstyles text-class []
  {:word-wrap "break-word"
   :word-break "break-all"
   :white-space "pre-wrap"})

(defn- render-header [id name trip ts show-link?]
  (let [res-name (if (nil? name) "Anonymous" name)]
    [:div {:class (header-class)}
     [:div {:class (header-item-class)}
      [:div {:class (header-item-number-class)} "#" id]]
     [:div {:class (header-item-class)}
      [:div {:class (header-item-name-container-class)}
       [:div {:class (header-item-name-class)} res-name]
       (when (not (nil? trip))
         [:div {:class (header-item-trip-class)} "!" trip])]]
     [:div {:class (header-item-class)}
      [:div (-> ts (* 1000) ts->iso)]]
     (when show-link?
       [:div {:class (header-item-class)}
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
               show-link?
               op?]}]
    [:div {:class (root-class (if op? "100%" "250px"))}
     (render-header id name trip ts show-link?)
     [:div {:class (text-class)} text]]))
