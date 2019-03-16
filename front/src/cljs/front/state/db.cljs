(ns front.state.db)


(def default-thread {:posts []
                     :loading? false
                     :error nil})

(def default-answer {:data {:name ""
                            :secret ""
                            :password ""
                            :text ""}
                     :status {:error nil
                              :in-progress? false}})

(def default-new-thread
  (assoc-in default-answer [:data :subject] ""))

(def default-db {:threads {:list []
                           :loading? false
                           :error nil}

                 :thread default-thread

                 :answer default-answer
                 :new-thread default-new-thread

                 :router {:current-page :undefined
                          :params []}})