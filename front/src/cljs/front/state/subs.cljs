(ns front.state.subs
  (:require [re-frame.core :refer [subscribe reg-sub]]))


(reg-sub :threads-root #(:threads %))
(reg-sub
  :threads
  :<- [:threads-root]
  (fn [root _] (:list root)))
(reg-sub
  :sorted-threads
  :<- [:threads]
  (fn [threads _] (reverse threads)))
(reg-sub
  :threads-loading?
  :<- [:threads-root]
  (fn [root _] (:loading? root)))
(reg-sub
  :threads-error
  :<- [:threads-root]
  (fn [root _] (:error root)))

(reg-sub :thread-root #(:thread %))
(reg-sub
  :thread-posts
  :<- [:thread-root]
  (fn [root _] (:posts root)))
(reg-sub
  :thread-loading?
  :<- [:thread-root]
  (fn [root _] (:loading? root)))
(reg-sub
  :thread-error
  :<- [:thread-root]
  (fn [root _] (:error root)))

(reg-sub
  :minor-loading?
  :<- [:threads-loading?]
  :<- [:thread-loading?]
  :<- [:threads]
  :<- [:thread-posts]
  (fn [[threads-loading?
        thread-loading?
        threads
        thread-posts]
       _]
    (or (and threads-loading? (-> threads empty? not))
        (and thread-loading? (-> thread-posts empty? not)))))

(reg-sub :router #(:router %))
(reg-sub
  :current-page
  :<- [:router]
  (fn [root _] (:current-page root)))
(reg-sub
  :route-params
  :<- [:router]
  (fn [root _] (:params root)))
(reg-sub
  :threads-page?
  :<- [:current-page]
  (fn [page _] (= page :threads)))

; It is no a best way to do so
; TODO: Make it less generic
(reg-sub :new-thread #(:new-thread %))
(reg-sub :answer #(:answer %))