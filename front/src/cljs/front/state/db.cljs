(ns front.state.db)


(def default-db {:threads []
                 :threads-loading? true
                 :threads-error nil
                 :thread-posts []
                 :current-page :undefined
                 :route-params []

                 :routes {}})