(ns front.components.create-new
  (:require
    [front.components.styles :as s]
    [cljss.core :refer-macros [defstyles] :as css]
    [re-frame.core :refer [subscribe dispatch]]))


(def font-size "11px")

(defstyles root-class []
  {:position "relative"
   :display "grid"
   :width "100%"
   :height "100%"
   :grid-template-columns "auto"
   :grid-template-rows "repeat(4, max-content) auto max-content"
   :grid-row-gap "5px"
   :font-size font-size})

(defstyles title-container-class []
  {:display "flex"
   :justify-content "space-between"
   :align-items "center"
   :padding-bottom "10px"})

(defstyles title-class []
  {:font-size "18px"
   :font-weight "400"})

(defstyles close-class []
  {:font-size "14px"
   :font-weight "500"
   :cursor "pointer"
   :&:hover {:opacity 0.7}
   ::css/media {[[:min-width "900px"]]
                {:display "none"}}})

(defstyles inputs-class []
  {:display "grid"
   :grid-template-columns "max-content auto"
   :align-items "center"
   :grid-column-gap "15px"
   :grid-row-gap "5px"
   :width "100%"})

(defstyles separator-class []
  {:height "15px"})

(defstyles message-label-class []
  {:padding-bottom "5px"})

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
      [:div {:class (root-class)}
       [:div {:class (title-container-class)}
        [:div {:class (title-class)} title]
        [:div {:class (close-class)
               :on-click on-close}
         "Close"]]
       [:div {:class (inputs-class)}
        [:div "Name"]
        [:input {:class (s/input-class font-size)
                 :placeholder "Anonymous"
                 :value (:name data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-name (-> % .-target .-value)])}]
        (when threads-page?
          [:<>
           [:div "Subject"]
           [:input {:class (s/input-class font-size)
                    :value (:subject data)
                    :disabled in-progress?
                    :on-change #(dispatch [:change-subject (-> % .-target .-value)])}]])
        [:div "Trip secret"]
        [:input {:class (s/input-class font-size)
                 :value (:secret data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-secret (-> % .-target .-value)])}]
        [:div "Password"]
        [:input {:class (s/input-class font-size)
                 :type "password"
                 :value (:password data)
                 :disabled in-progress?
                 :on-change #(dispatch [:change-password (-> % .-target .-value)])}]]
       [:div {:class (separator-class)}]
       [:div {:class (message-label-class)} "Message"]
       [:textarea {:class (s/textarea-class font-size)
                   :placeholder "Your message"
                   :value (:text data)
                   :disabled in-progress?
                   :on-change #(dispatch [:change-msg (-> % .-target .-value)])}]
       [:button {:class (s/primary-button-class font-size)
                 :disabled (or in-progress? (empty? (:text data)))
                 :on-click #(dispatch
                             [:post-msg
                              (merge {:on-success on-success}
                                     (when (-> thread-id nil? not)
                                       {:thread thread-id}))])}
        (if in-progress? "Creating..." "Post")]])))
