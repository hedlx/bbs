(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]
    [front.styles.colors :as colors]
    [re-frame.core :refer [subscribe]]
    [cljss.core :refer-macros [defstyles]]
    [clojure.string :as str]))


(defstyles thread-class []
  {:width "100%"})

(defstyles separator-class []
           {:width "97%"
            :height "1px"
            :margin-top "20px"
            :margin-bottom "20px"
            :border 0
            :border-top (str/join " " ["1px dashed" colors/light-purple])
            :color colors/light-purple})

(defstyles root-class []
  {:position "relative"
   :display "flex"
   :flex-direction "column"
   :align-items "flex-start"
   :width "100%"
   :height "100%"})

(defstyles subject-class []
  {:font-size "18px"
   :font-weight 300
   :color colors/yellow
   :padding-bottom "15px"})

(defn- render-thread [thread]
  (let [{:keys [subject id]} thread]
    [:<> {:key (str "thread" id)}
     (when (-> subject nil? not)
       [:div {:class (subject-class)} subject])
     [:div {:class (thread-class)}
          [thread-comp/c {:thread thread}]]]))

(defn- render-separator [key]
  ^{:key key} [:hr {:class (separator-class)}])

(defn- render-threads [threads]
  (->> threads
       (map-indexed
         (fn [idx thread] [(render-thread thread) (render-separator (str idx "s"))]))
       (apply concat)
       (butlast)))

(defn- render-content [threads error]
  (cond
    error    [:div "ERROR"] ;TODO: you know
    :default (render-threads threads)))

(defn page []
  (let [threads @(subscribe [:sorted-threads])
        error @(subscribe [:threads-error])]
    [:div {:class (root-class)}
      (render-content threads error)]))
