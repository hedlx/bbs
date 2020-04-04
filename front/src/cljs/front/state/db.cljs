(ns front.state.db)


(def default-window {:width 0
                     :height 0})

(def default-limits {:values {}
                     :loading? false
                     :loaded? false
                     :error nil})

(def default-thread {:posts []
                     :subject nil
                     :loading? false
                     :error nil})

(def default-answer {:data {:name ""
                            :secret ""
                            :password ""
                            :text ""
                            :media {}}
                     :status {:error nil
                              :in-progress? false}})

(def default-new-thread
  (assoc-in default-answer [:data :subject] ""))

(def default-db {:base-url ""
                 :base-api-url ""
                 :window default-window
                 :default-limits {}
                 
                 :threads {:list []
                           :loading? false
                           :error nil}

                 :thread default-thread

                 :answer default-answer
                 :new-thread default-new-thread

                 :router {:current-page :undefined
                          :params []}})
