if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'student_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/connections', (->
        @layout 'profile_layout'
        @render 'user_connections'
        ), name:'user_connections'
    Router.route '/user/:username/karma', (->
        @layout 'profile_layout'
        @render 'user_karma'
        ), name:'user_karma'
    Router.route '/user/:username/payment', (->
        @layout 'profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/user/:username/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/workhistory', (->
        @layout 'profile_layout'
        @render 'user_workhistory'
        ), name:'user_workhistory'
    Router.route '/user/:username/offers', (->
        @layout 'profile_layout'
        @render 'user_offers'
        ), name:'user_offers'
    Router.route '/user/:username/contact', (->
        @layout 'profile_layout'
        @render 'user_contact'
        ), name:'user_contact'
    Router.route '/user/:username/stats', (->
        @layout 'profile_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/user/:username/votes', (->
        @layout 'profile_layout'
        @render 'user_votes'
        ), name:'user_votes'
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/tags', (->
        @layout 'profile_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/user/:username/tasks', (->
        @layout 'profile_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/user/:username/transactions', (->
        @layout 'profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/gallery', (->
        @layout 'profile_layout'
        @render 'user_gallery'
        ), name:'user_gallery'
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/bookmarks', (->
        @layout 'profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:username/documents', (->
        @layout 'profile_layout'
        @render 'user_documents'
        ), name:'user_documents'
    Router.route '/user/:username/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'
    Router.route '/user/:username/products', (->
        @layout 'profile_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/comparison', (->
        @layout 'profile_layout'
        @render 'user_comparison'
        ), name:'user_comparison'
    Router.route '/user/:username/notifications', (->
        @layout 'profile_layout'
        @render 'user_notifications'
        ), name:'user_notifications'


    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'student_stats', Router.current().params.username

    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.profile_layout.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id


        user_events: ->
            Docs.find
                model:'classroom_event'
        user_credits: ->
            Docs.find
                model:'classroom_event'
                event_type:'credit'
        user_debits: ->
            Docs.find
                model:'classroom_event'
                event_type:'debit'
        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.profile_layout.events
        'click .recalc_student_stats': ->
            Meteor.call 'recalc_student_stats', Router.current().params.username
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()



if Meteor.isServer
    Meteor.publish 'user_events', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'classroom_event'
            user_id:user._id

    Meteor.publish 'student_stats', (username)->
        user = Meteor.users.findOne username:username
        if user
            Docs.find
                model:'student_stats'
                user_id:user._id


    Meteor.methods
        recalc_student_stats: (username)->
            user = Meteor.users.findOne username:username
            user_id = user._id
            # console.log classroom
            student_stats_doc = Docs.findOne
                model:'student_stats'
                user_id: user_id

            unless student_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'student_stats'
                    user_id: user_id
                student_stats_doc = Docs.findOne new_stats_doc_id

            debits = Docs.find({
                model:'classroom_event'
                event_type:'debit'
                user_id:user_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                user_id:user_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            student_balance = total_credit_amount-total_debit_amount

            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count


            Docs.update student_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    student_balance: student_balance
