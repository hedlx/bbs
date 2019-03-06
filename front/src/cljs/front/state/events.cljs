(ns front.state.events
  (:require [re-frame.core :refer [reg-event-db reg-event-fx]]
            [day8.re-frame.http-fx]
            [ajax.core :refer [json-request-format json-response-format]]
            [front.state.db :refer [default-db]]
            [front.state.util :refer [gen-url]]))


(reg-event-db
  :initialize
  (fn [_ [_ {:keys [base-url]}]]
    (assoc default-db :base-url base-url)))

(reg-event-fx
  :change-location
  (fn [{:keys [db]} [_ {:keys [current-page route-params]}]]
    (let [router-fx (-> db
                        (assoc-in [:router :current-page] current-page)
                        (assoc-in [:router :params] route-params))]
      (case current-page
        :threads {:db router-fx
                  :dispatch [:load-threads]}))))

(reg-event-fx
  :load-threads
  (fn [{:keys [db]}, _]
    {:http-xhrio {:method "get"
                  :uri (gen-url (:base-url db) "threads")
                  :format (json-request-format)
                  :response-format (json-response-format {:keywords? true})
                  :on-success [:threads-fetch-success]
                  :on-failure [:threads-fetch-error]}
     :db (assoc-in db [:threads :loading?] true)}))

(reg-event-db
  :threads-fetch-success
  (fn [db [_ threads]]
    (-> db
        (assoc-in [:threads :list] threads)
        (assoc-in [:threads :loading?] false)
        (assoc-in [:threads :error] nil))))

(reg-event-db
  :threads-fetch-error
  (fn [db [_ error]]
    (-> db
        (assoc-in [:threads :list] [])
        (assoc-in [:threads :loading?] false)
        (assoc-in [:threads :error] error))))