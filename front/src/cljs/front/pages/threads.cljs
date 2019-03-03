(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]))


(def default-threads
  [{:id 0 :name "test" :text "Пацаны, есть одна тян..."}
   {:id 1 :text "Куклонить стартует здесь"}])

(defn render-thread [thread]
  ^{:key (:id thread)}
  [:div {:class "pa1"}
        [thread-comp/c {:thread thread}]])

(defn page []
  (fn [{:keys [threads] :or {threads default-threads}}]
    [:div {:class "w-100 flex flex-column"}
      (map render-thread threads)]))
