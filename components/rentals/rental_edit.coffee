if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_info'
        ), name:'rental_edit'
    Router.route '/rental/:doc_id/edit/info', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_info'
        ), name:'rental_edit_info'
    Router.route '/rental/:doc_id/edit/finance', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_finance'
        ), name:'rental_edit_finance'
    Router.route '/rental/:doc_id/edit/chat', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_chat'
        ), name:'rental_edit_chat'
    Router.route '/rental/:doc_id/edit/ads', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_ads'
        ), name:'rental_edit_ads'
    Router.route '/rental/:doc_id/edit/ownership', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_ownership'
        ), name:'rental_edit_ownership'
    Router.route '/rental/:doc_id/edit/availability', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_availability'
        ), name:'rental_edit_availability'
    Router.route '/rental/:doc_id/edit/stats', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_stats'
        ), name:'rental_edit_stats'
    Router.route '/rental/:doc_id/edit/tasks', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_tasks'
        ), name:'rental_edit_tasks'
    Router.route '/rental/:doc_id/edit/audience', (->
        @layout 'rental_edit_layout'
        @render 'rental_edit_audience'
        ), name:'rental_edit_audience'
