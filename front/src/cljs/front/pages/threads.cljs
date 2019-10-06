(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]
    [re-frame.core :refer [subscribe]]))


(defn- render-thread [thread]
  (let [{:keys [subject id]} thread]
    [:<> {:key (str "thread" id)}
     (when (-> subject nil? not)
       [:div {:class "threads-thread-subject"} subject])
     [:div {:class "threads-thread"}
          [thread-comp/c {:thread thread}]]]))

(defn- render-separator [key]
  ^{:key key} [:hr {:class "threads-separator"}])

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
    [:div {:class "threads"}
      (render-content threads error)]))
