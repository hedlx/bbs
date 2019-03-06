(ns front.state.db)


(def default-db {:threads {:list []
                           :loading? false
                           :error nil}
                 :thread-posts []
                 :router {:current-page :undefined
                          :params []}})