if Meteor.isClient
    Router.route '/teacher/:username', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_dashboard'
        ), name:'teacher_profile_layout'
    Router.route '/teacher/:username/about', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_about'
        ), name:'teacher_about'
    Router.route '/teacher/:username/connections', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_connections'
        ), name:'teacher_connections'
    Router.route '/teacher/:username/karma', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_karma'
        ), name:'teacher_karma'
    Router.route '/teacher/:username/services', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_services'
        ), name:'teacher_services'
    Router.route '/teacher/:username/payment', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_payment'
        ), name:'teacher_payment'
    Router.route '/teacher/:username/finance', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_finance'
        ), name:'teacher_finance'
    Router.route '/teacher/:username/offers', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_offers'
        ), name:'teacher_offers'
    Router.route '/teacher/:username/contact', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_contact'
        ), name:'teacher_contact'
    Router.route '/teacher/:username/reports', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_reports'
        ), name:'teacher_reports'
    Router.route '/teacher/:username/stats', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_stats'
        ), name:'teacher_stats'
    Router.route '/teacher/:username/shop', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_shop'
        ), name:'teacher_shop'
    Router.route '/teacher/:username/votes', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_votes'
        ), name:'teacher_votes'
    Router.route '/teacher/:username/dashboard', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_profile_dashboard'
        ), name:'teacher_profile_dashboard'
    Router.route '/teacher/:username/jobs', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_jobs'
        ), name:'teacher_jobs'
    Router.route '/teacher/:username/stock', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_stock'
        ), name:'teacher_stock'
    Router.route '/teacher/:username/requests', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_requests'
        ), name:'teacher_requests'
    Router.route '/teacher/:username/feed', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_feed'
        ), name:'teacher_feed'
    Router.route '/teacher/:username/tags', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_tags'
        ), name:'teacher_tags'
    Router.route '/teacher/:username/bids', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_bids'
        ), name:'teacher_bids'
    Router.route '/teacher/:username/tasks', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_tasks'
        ), name:'teacher_tasks'
    Router.route '/teacher/:username/transactions', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_transactions'
        ), name:'teacher_transactions'
    Router.route '/teacher/:username/gallery', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_gallery'
        ), name:'teacher_gallery'
    Router.route '/teacher/:username/messages', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_messages'
        ), name:'teacher_messages'
    Router.route '/teacher/:username/bookmarks', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_bookmarks'
        ), name:'teacher_bookmarks'
    Router.route '/teacher/:username/documents', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_documents'
        ), name:'teacher_documents'
    Router.route '/teacher/:username/loans', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_loans'
        ), name:'teacher_loans'
    Router.route '/teacher/:username/social', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_social'
        ), name:'teacher_social'
    Router.route '/teacher/:username/events', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_events'
        ), name:'teacher_events'
    Router.route '/teacher/:username/products', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_products'
        ), name:'teacher_products'
    Router.route '/teacher/:username/comparison', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_comparison'
        ), name:'teacher_comparison'
    Router.route '/teacher/:username/notifications', (->
        @layout 'teacher_profile_layout'
        @render 'teacher_notifications'
        ), name:'teacher_notifications'


    Template.teacher_profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'teacher_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'teacher_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'teacher_stats', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'teacher_section'

    Template.teacher_profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Session.setDefault 'view_side', false

    Template.teacher_profile_layout.helpers
        route_slug: -> "teacher_#{@slug}"
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        teacher_sections: ->
            Docs.find {
                model:'teacher_section'
            }, sort:title:1
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'teacher_stats'
                teacher_id:user._id
        view_side: -> Session.get 'view_side'
        main_column_class: ->
            if Session.get 'view_side'
                'fourteen wide column'
            else
                'sixteen wide column'
        teacher_events: ->
            Docs.find
                model:'classroom_event'
        teacher_credits: ->
            Docs.find
                model:'classroom_event'
                event_type:'credit'
        teacher_debits: ->
            Docs.find
                model:'classroom_event'
                event_type:'debit'
        teacher_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.teacher_profile_layout.events
        'click .toggle_size': ->
            Session.set 'view_side', !Session.get('view_side')
        'click .recalc_teacher_stats': ->
            Meteor.call 'recalc_teacher_stats', Router.current().params.username
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()



if Meteor.isServer
    Meteor.publish 'teacher_events', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'classroom_event'
            teacher_id:user._id

    Meteor.publish 'teacher_stats', (username)->
        user = Meteor.users.findOne username:username
        if user
            Docs.find
                model:'teacher_stats'
                teacher_id:user._id


    Meteor.methods
        recalc_teacher_stats: (username)->
            user = Meteor.users.findOne username:username
            teacher_id = user._id
            # console.log classroom
            teacher_stats_doc = Docs.findOne
                model:'teacher_stats'
                teacher_id: teacher_id

            unless teacher_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'teacher_stats'
                    teacher_id: teacher_id
                teacher_stats_doc = Docs.findOne new_stats_doc_id

            debits = Docs.find({
                model:'classroom_event'
                event_type:'debit'
                teacher_id:teacher_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                teacher_id:teacher_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            teacher_balance = total_credit_amount-total_debit_amount

            # average_credit_per_student = total_credit_amount/teacher_count
            # average_debit_per_student = total_debit_amount/teacher_count


            Docs.update teacher_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    teacher_balance: teacher_balance
