(ns front.components.create-new
  (:require
    [re-frame.core :refer [subscribe dispatch]]))

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
          target-form (if threads-page? @(subscribe [:new-thread])
                                        @(subscribe [:answer]))
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
        [:input {:placeholder "Anonymous"
                 :value (:name data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-name (-> % .-target .-value)])}]
        (when threads-page?
          [:<>
           [:div "Subject"]
           [:input {:value (:subject data)
                    :disabled in-progress?
                    :on-change #(dispatch [:change-subject (-> % .-target .-value)])}]])
        [:div "Trip secret"]
        [:input {:value (:secret data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-secret (-> % .-target .-value)])}]
        [:div "Password"]
        [:input {:type "password"
                 :value (:password data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-password (-> % .-target .-value)])}]]
       [:div {:class "create-new-separator"}]
       [:div {:class "create-new-message-label"} "Message"]
       [:textarea {:placeholder "Your message"
                   :value (:text data)
                   :disabled in-progress?
                   :on-change #(dispatch [:change-msg (-> % .-target .-value)])}]
       [:button {:class "primary"
                 :disabled (or in-progress? (empty? (:text data)))
                 :on-click #(dispatch
                             [:post-msg
                              (merge {:on-success on-success}
                                     (when (-> thread-id nil? not)
                                       {:thread thread-id}))])}
        (if in-progress? "Creating..." "Post")]])))
