(ns front.state.events
  (:require [re-frame.core :refer [reg-event-db reg-event-fx]]
            [day8.re-frame.http-fx]
            [ajax.core :refer [json-request-format json-response-format]]
            [front.state.db :refer [default-db default-thread]]
            [front.state.util :refer [gen-url]]))


(reg-event-db
  :initialize
  (fn [_ [_ {:keys [base-url]}]]
    (assoc default-db :base-url base-url)))

(reg-event-fx
  :change-location
  (fn [{:keys [db]} [_ {:keys [current-page params]}]]
    (let [router-fx (-> db

                        (assoc :thread default-thread)
                        (assoc-in [:router :current-page] current-page)
                        (assoc-in [:router :params] params))]
      (case current-page
        :threads {:db router-fx
                  :dispatch [:load-threads]}
        :thread {:db router-fx
                 :dispatch [:load-thread params]}))))

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

(reg-event-fx
  :load-thread
  (fn [{:keys [db]}, [_ {:keys [id]}]]
    {:http-xhrio {:method "get"
                  :uri (gen-url (:base-url db) "threads" id)
                  :format (json-request-format)
                  :response-format (json-response-format {:keywords? true})
                  :on-success [:thread-fetch-success]
                  :on-failure [:thread-fetch-error]}
     :db (assoc-in db [:thread :loading?] true)}))

(reg-event-db
  :thread-fetch-success
  (fn [db [_ posts]]
    (-> db
        (assoc-in [:thread :posts] posts)
        (assoc-in [:thread :loading?] false)
        (assoc-in [:thread :error] nil))))

(reg-event-db
  :thread-fetch-error
  (fn [db [_ error]]
    (-> db
        (assoc-in [:thread :posts] [])
        (assoc-in [:thread :loading?] false)
        (assoc-in [:thread :error] error))))