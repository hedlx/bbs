(ns front.state.db)

(def default-thread {:posts []
                     :loading? false
                     :error nil})

(def default-db {:threads {:list []
                           :loading? false
                           :error nil}

                 :thread default-thread

                 :router {:current-page :undefined
                          :params []}})