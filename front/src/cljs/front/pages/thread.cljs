(ns front.pages.thread
  (:require
    [front.components.post :as post]
    [front.components.spinner-overlay :as spinner-overlay]
    [front.styles.colors :as colors]
    [cljss.core :refer-macros [defstyles]]
    [re-frame.core :refer [subscribe]]
    [clojure.string :as str]))


(defstyles post-class [full-width?]
  {:padding "2px"
   :width (if full-width? "100%" "auto")})

(defstyles subject-class []
           {:font-size "18px"
            :font-weight 300
            :color colors/yellow
            :padding-bottom "15px"})

(defstyles root-class []
  {:position "relative"
   :display "flex"
   :flex-direction "column"
   :align-items "flex-start"
   :width "100%"
   :height "100%"})

(defn- render-post [post]
  (let [id (:no post)
        op? (zero? id)]
    ^{:key id}
    [:div {:class (post-class op?)}
     [post/c (assoc post :id id :op? op?)]]))

(defn- render-posts [posts]
  (map render-post posts))

(defn- render-content [posts loading? error]
  (cond
    (and (empty? posts) loading?) [spinner-overlay/c]
    error [:div "ERROR"] ;TODO: you know
    :default (render-posts posts)))

(defn page []
  (fn []
    (let [subject @(subscribe [:thread-subject])
          posts @(subscribe [:thread-posts])
          loading? @(subscribe [:thread-loading?])
          error @(subscribe [:thread-error])]
      [:<>
       (when (-> subject nil? not)
         [:div {:class (subject-class)} subject])
       [:div {:class (root-class)}
        (render-content posts loading? error)]])))