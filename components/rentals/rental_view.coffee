if Meteor.isClient
    Router.route '/rental/:doc_id/view', (->
        @layout 'rental_view_layout'
        @render 'rental_view_info'
        ), name:'rental_view_info'
    Router.route '/rental/:doc_id/finance', (->
        @layout 'rental_view_layout'
        @render 'rental_view_finance'
        ), name:'rental_view_finance'
    Router.route '/rental/:doc_id/transactions', (->
        @layout 'rental_view_layout'
        @render 'rental_view_transactions'
        ), name:'rental_view_transactions'
    Router.route '/rental/:doc_id/reservations', (->
        @layout 'rental_view_layout'
        @render 'rental_view_reservations'
        ), name:'rental_view_reservations'
    Router.route '/rental/:doc_id/chat', (->
        @layout 'rental_view_layout'
        @render 'rental_view_chat'
        ), name:'rental_view_chat'
    Router.route '/rental/:doc_id/calendar', (->
        @layout 'rental_view_layout'
        @render 'rental_view_calendar'
        ), name:'rental_view_calendar'
    Router.route '/rental/:doc_id/ads', (->
        @layout 'rental_view_layout'
        @render 'rental_view_ads'
        ), name:'rental_view_ads'
    Router.route '/rental/:doc_id/ownership', (->
        @layout 'rental_view_layout'
        @render 'rental_view_ownership'
        ), name:'rental_view_ownership'
    Router.route '/rental/:doc_id/availability', (->
        @layout 'rental_view_layout'
        @render 'rental_view_availability'
        ), name:'rental_view_availability'
    Router.route '/rental/:doc_id/stats', (->
        @layout 'rental_view_layout'
        @render 'rental_view_stats'
        ), name:'rental_view_stats'
    Router.route '/rental/:doc_id/tasks', (->
        @layout 'rental_view_layout'
        @render 'rental_view_tasks'
        ), name:'rental_view_tasks'
    Router.route '/rental/:doc_id/audience', (->
        @layout 'rental_view_layout'
        @render 'rental_view_audience'
        ), name:'rental_view_audience'


    Template.kiosk_rental_view.events
        'click .new_reservation': ->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/new_reservation/#{new_reservation_id}"


    Template.rental_view_info.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_view_info.onRendered ->
        # console.log @
        Meteor.call 'increment_view', @data._id, ->
