(ns front.state.events
  (:require [re-frame.core :refer [reg-event-db
                                   reg-event-fx]]
            [day8.re-frame.http-fx]
            [ajax.core :refer [json-request-format
                               json-response-format]]
            [front.state.db :refer [default-db
                                    default-thread
                                    default-answer
                                    default-new-thread]]
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
                        (assoc :answer default-answer)
                        (assoc-in [:router :current-page] current-page)
                        (assoc-in [:router :params] params))]
      (case current-page
        :threads {:db router-fx
                  :dispatch [:load-threads]}
        :thread {:db router-fx
                 :dispatch [:load-thread params]}
        {:db router-fx}))))

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
  (fn [db [_ thread]]
    (if (= (-> db :router :current-page) :thread)
      (-> db
          (assoc-in [:thread :posts] (:messages thread))
          (assoc-in [:thread :loading?] false)
          (assoc-in [:thread :error] nil))
      db)))

(reg-event-db
  :thread-fetch-error
  (fn [db [_ error]]
    (if (= (-> db :router :current-page) :thread)
      (-> db
          (assoc-in [:thread :posts] [])
          (assoc-in [:thread :loading?] false)
          (assoc-in [:thread :error] error))
      db)))

(defn- get-create-root [db]
  (if (= :threads (-> db :router :current-page))
    :new-thread
    :answer))

(reg-event-db
  :change-name
  (fn [db [_ name]]
    (assoc-in db [(get-create-root db) :data :name] name)))
(reg-event-db
  :change-subject
  (fn [db [_ subj]]
    (assoc-in db [(get-create-root db) :data :subject] subj)))
(reg-event-db
  :change-secret
  (fn [db [_ secret]]
    (assoc-in db [(get-create-root db) :data :secret] secret)))
(reg-event-db
  :change-password
  (fn [db [_ pass]]
    (assoc-in db [(get-create-root db) :data :password] pass)))
(reg-event-db
  :change-msg
  (fn [db [_ msg]]
    (assoc-in db [(get-create-root db) :data :text] msg)))

(reg-event-fx
  :post-msg
  (fn [{:keys [db]} [_ {:keys [thread on-success]}]]
    (let [new-thread? (nil? thread)
          target (if new-thread? :new-thread :answer)]
      (when (-> db target :in-progress? not)
        {:http-xhrio {:method "post"
                      :uri (gen-url (:base-url db)
                                    "threads"
                                    (when (not new-thread?) thread))
                      :params (-> db target :data)
                      :format (json-request-format)
                      :response-format (json-response-format {:keywords? true})
                      :on-success [(if new-thread?
                                     :post-thread-success
                                     :post-msg-success) on-success]
                      :on-failure [(if new-thread?
                                     :post-thread-error
                                     :post-msg-error)]}
         :db (-> db
                 (assoc-in [target :status :in-progress?] true)
                 (assoc-in [target :status :error] nil))}))))

(reg-event-fx
  :post-msg-success
  (fn [{:keys [db]} [_ on-success _]]
    (do
      (on-success)
      (if (= (-> db :router :current-page) :thread)
        {:db (assoc db :answer default-answer)
         :dispatch [:load-thread {:id (-> db :router :params :id)}]}
        {:db (assoc db :answer default-answer)}))))
(reg-event-db
  :post-msg-error
  (fn [db [_ error]]
    (if (= (-> db :router :current-page) :thread)
      (assoc-in db [:answer :status :error] error)
      (assoc db :answer default-answer))))

(reg-event-fx
  :post-thread-success
  (fn [{:keys [db]} [_ on-success _]]
    (do
      (on-success)
      (if (= (-> db :router :current-page) :threads)
        {:db (assoc db :new-thread default-new-thread)
         :dispatch [:load-threads]}
        {:db (assoc db :new-thread default-new-thread)}))))
(reg-event-db
  :post-thread-error
  (fn [db [_ error]]
    (if (= (-> db :router :current-page) :threads)
      (assoc-in db [:new-thread :status :error] error)
      (assoc db :new-thread default-new-thread))))