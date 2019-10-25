if Meteor.isClient
    Router.route '/leader/:username', (->
        @layout 'leader_profile_layout'
        @render 'leader_dashboard'
        ), name:'leader_profile_layout'
    Router.route '/leader/:username/about', (->
        @layout 'leader_profile_layout'
        @render 'leader_about'
        ), name:'leader_about'
    Router.route '/leader/:username/connections', (->
        @layout 'leader_profile_layout'
        @render 'leader_connections'
        ), name:'leader_connections'
    Router.route '/leader/:username/dashboard', (->
        @layout 'leader_profile_layout'
        @render 'leader_profile_dashboard'
        ), name:'leader_profile_dashboard'
    Router.route '/leader/:username/jobs', (->
        @layout 'leader_profile_layout'
        @render 'leader_jobs'
        ), name:'leader_jobs'
    Router.route '/leader/:username/stock', (->
        @layout 'leader_profile_layout'
        @render 'leader_stock'
        ), name:'leader_stock'
    Router.route '/leader/:username/requests', (->
        @layout 'leader_profile_layout'
        @render 'leader_requests'
        ), name:'leader_requests'
    Router.route '/leader/:username/feed', (->
        @layout 'leader_profile_layout'
        @render 'leader_feed'
        ), name:'leader_feed'
    Router.route '/leader/:username/tags', (->
        @layout 'leader_profile_layout'
        @render 'leader_tags'
        ), name:'leader_tags'
    Router.route '/leader/:username/bids', (->
        @layout 'leader_profile_layout'
        @render 'leader_bids'
        ), name:'leader_bids'
    Router.route '/leader/:username/tasks', (->
        @layout 'leader_profile_layout'
        @render 'leader_tasks'
        ), name:'leader_tasks'
    Router.route '/leader/:username/transactions', (->
        @layout 'leader_profile_layout'
        @render 'leader_transactions'
        ), name:'leader_transactions'
    Router.route '/leader/:username/gallery', (->
        @layout 'leader_profile_layout'
        @render 'leader_gallery'
        ), name:'leader_gallery'
    Router.route '/leader/:username/messages', (->
        @layout 'leader_profile_layout'
        @render 'leader_messages'
        ), name:'leader_messages'
    Router.route '/leader/:username/bookmarks', (->
        @layout 'leader_profile_layout'
        @render 'leader_bookmarks'
        ), name:'leader_bookmarks'
    Router.route '/leader/:username/documents', (->
        @layout 'leader_profile_layout'
        @render 'leader_documents'
        ), name:'leader_documents'
    Router.route '/leader/:username/loans', (->
        @layout 'leader_profile_layout'
        @render 'leader_loans'
        ), name:'leader_loans'
    Router.route '/leader/:username/social', (->
        @layout 'leader_profile_layout'
        @render 'leader_social'
        ), name:'leader_social'
    Router.route '/leader/:username/events', (->
        @layout 'leader_profile_layout'
        @render 'leader_events'
        ), name:'leader_events'
    Router.route '/leader/:username/products', (->
        @layout 'leader_profile_layout'
        @render 'leader_products'
        ), name:'leader_products'
    Router.route '/leader/:username/comparison', (->
        @layout 'leader_profile_layout'
        @render 'leader_comparison'
        ), name:'leader_comparison'
    Router.route '/leader/:username/notifications', (->
        @layout 'leader_profile_layout'
        @render 'leader_notifications'
        ), name:'leader_notifications'


    Template.leader_profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'leader_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'leader_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'leader_stats', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'leader_section'

    Template.leader_profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Session.setDefault 'view_side', false

    Template.leader_profile_layout.helpers
        route_slug: -> "leader_#{@slug}"
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        leader_sections: ->
            Docs.find {
                model:'leader_section'
            }, sort:title:1
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'leader_stats'
                leader_id:user._id
        view_side: -> Session.get 'view_side'
        main_column_class: ->
            if Session.get 'view_side'
                'fourteen wide column'
            else
                'sixteen wide column'
        leader_events: ->
            Docs.find
                model:'group_event'
        leader_credits: ->
            Docs.find
                model:'group_event'
                event_type:'credit'
        leader_debits: ->
            Docs.find
                model:'group_event'
                event_type:'debit'
        leader_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.leader_profile_layout.events
        'click .toggle_size': ->
            Session.set 'view_side', !Session.get('view_side')
        'click .recalc_leader_stats': ->
            Meteor.call 'recalc_leader_stats', Router.current().params.username
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()



if Meteor.isServer
    Meteor.publish 'leader_events', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group_event'
            leader_id:user._id

    Meteor.publish 'leader_stats', (username)->
        user = Meteor.users.findOne username:username
        if user
            Docs.find
                model:'leader_stats'
                leader_id:user._id


    Meteor.methods
        recalc_leader_stats: (username)->
            user = Meteor.users.findOne username:username
            leader_id = user._id
            # console.log group
            leader_stats_doc = Docs.findOne
                model:'leader_stats'
                leader_id: leader_id

            unless leader_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'leader_stats'
                    leader_id: leader_id
                leader_stats_doc = Docs.findOne new_stats_doc_id

            debits = Docs.find({
                model:'group_event'
                event_type:'debit'
                leader_id:leader_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'group_event'
                event_type:'credit'
                leader_id:leader_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            leader_balance = total_credit_amount-total_debit_amount

            # average_credit_per_member = total_credit_amount/leader_count
            # average_debit_per_member = total_debit_amount/leader_count


            Docs.update leader_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    leader_balance: leader_balance
