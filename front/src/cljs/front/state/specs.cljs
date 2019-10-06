(ns front.state.specs
  (:require [clojure.spec.alpha :as s]))

(def initialized? (atom  false))

(defn reg-create-msg-specs [limits]
  (when (not @initialized?)
    (reset! initialized? true)
    (s/def ::name (s/and string? #(<= (count %) (:msg-name-len limits))))
    (s/def ::secret string?)
    (s/def ::password string?)
    (s/def ::text (s/and string? #(<= (count %) (:msg-text-len limits))))
    (s/def ::subject (s/and string? #(<= (count %) (:msg-subject-len limits))))
    (s/def ::new-thread 
      (s/and (s/keys :req-un [::name ::secret ::password ::text ::subject])
             (fn [{:keys [text]}] (> (count text) 0))))
    (s/def ::new-answer
      (s/and (s/keys :req-un [::name ::secret ::password ::text])
             (fn [{:keys [text]}] (> (count text) 0))))))