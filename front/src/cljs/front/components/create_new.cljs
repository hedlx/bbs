(ns front.components.create-new
  (:require
   [re-frame.core :refer [subscribe dispatch]]
   [clojure.spec.alpha :as s]
   [front.state.specs :as specs]
   [front.components.dropzone :as dropzone]))

(defn c [{:keys [on-success on-close]}]
  (fn []
    (let [page @(subscribe [:current-page])
          threads-page? (= :threads page)
          thread-id (when (= :thread page)
                      (:id @(subscribe [:route-params])))
          title (case page
                  :threads "Create thread"
                  :thread "Add message"
                  "Dunno what you want")
          target-form (if threads-page?
                        @(subscribe [:new-thread])
                        @(subscribe [:answer]))
          target-spec (if threads-page?
                        ::specs/new-thread
                        ::specs/new-answer)
          {:keys [data status]} target-form
          {:keys [in-progress?]} status]
      [:div {:class "create-new"}
       [:div {:class "create-new-title-container"}
        [:div {:class "create-new-title"} title]
        [:div {:class "create-new-close"
               :on-click on-close}
         "Close"]]
       [:div {:class "create-new-inputs"}
        [:div "Name"]
        [:input {:class (when-not (s/valid? ::specs/name (:name data)) "error")
                 :placeholder "Anonymous"
                 :value (:name data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-name (-> % .-target .-value)])}]
        (when threads-page?
          [:<>
           [:div "Subject"]
           [:input {:class (when-not (s/valid? ::specs/subject (:subject data)) "error")
                    :value (:subject data)
                    :disabled in-progress?
                    :on-change #(dispatch [:change-subject (-> % .-target .-value)])}]])
        [:div "Trip secret"]
        [:input {:class (when-not (s/valid? ::specs/secret (:secret data)) "error")
                 :value (:secret data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-secret (-> % .-target .-value)])}]
        [:div "Password"]
        [:input {:class (when-not (s/valid? ::specs/password (:password data)) "error")
                 :type "password"
                 :value (:password data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-password (-> % .-target .-value)])}]]
       [:div {:class "create-new-separator"}]
       [:div {:class "create-new-message-label"} "Message"]
       [:div {:class "create-new-message"}
        [:textarea {:class (when-not (s/valid? ::specs/text (:text data)) "error")
                    :placeholder "Your message"
                    :value (:text data)
                    :disabled in-progress?
                    :on-change #(dispatch [:change-msg (-> % .-target .-value)])}]]
       [:div {:class "create-new-dropzone"}
        [dropzone/c {:on-drop #(doseq [file %] (dispatch [:add-img {:file file}]))}]]
       [:div {:class "create-new-button"}
        [:button {:class "primary"
                  :disabled (or in-progress? (not (s/valid? target-spec data)))
                  :on-click #(dispatch
                              [:post-msg
                               (merge {:on-success on-success}
                                      (when (-> thread-id nil? not)
                                        {:thread thread-id}))])}
         (if in-progress? "Creating..." "Post")]]])))
