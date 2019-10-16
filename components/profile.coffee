if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile_view'
        ), name:'profile_view'


    Template.profile_view.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'student_stats', Router.current().params.username

    Template.profile_view.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.profile_view.helpers
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


    Template.profile_view.events
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
