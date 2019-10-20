if Meteor.isClient
    Router.route '/questions', (->
        @layout 'layout'
        @render 'questions'
        ), name:'questions'
    Router.route '/question/:doc_id/edit', (->
        @layout 'layout'
        @render 'question_edit'
        ), name:'question_edit'
    Router.route '/question/:doc_id/view', (->
        @layout 'layout'
        @render 'question_view'
        ), name:'question_view'



    Template.question_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.question_edit.events
        'click .add_question_item': ->
            new_mi_id = Docs.insert
                model:'question_item'
            Router.go "/question/#{_id}/edit"
    Template.question_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
    Template.question_edit.events
        'click .add_choice': ->
            console.log @
            Docs.insert
                model:'choice'
                question_id:@_id


    Template.question_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'bounty'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'answer_sessions_from_question_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.question_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.question_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        bounties: ->
            Docs.find
                model:'bounty'
                question_id:@_id
        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: Router.current().params.doc_id

        answer_sessions: ->
            Docs.find
                model:'answer_session'
                question_id: Router.current().params.doc_id

        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    question_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true

    Template.question_view.events
        'click .new_answer_session': ->
            # console.log @
            new_answer_session_id = Docs.insert
                model:'answer_session'
                question_id: Router.current().params.doc_id
            Router.go "/answer_session/#{new_answer_session_id}/edit"
        'click .offer_bounty': ->
            console.log @
            new_bounty_id = Docs.insert
                model:'bounty'
                question_id:@_id
            Router.go "/bounty/#{new_bounty_id}/edit"

        'click .accept': ->
            console.log @





    Template.questions.onRendered ->
        # @autorun => Meteor.subscribe 'model_docs', 'question'
    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'




    Template.questions.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
            Router.go "/question/#{new_question_id}/edit"



    Template.question_stats.events
        'click .refresh_question_stats': ->
            Meteor.call 'refresh_question_stats', @_id




if Meteor.isServer
    Meteor.publish 'answer_sessions_from_question_id', (question_id)->
        Docs.find
            model:'answer_session'
            question_id:question_id
    Meteor.publish 'questions', (product_id)->
        Docs.find
            model:'question'
            product_id:product_id

    Meteor.methods
        refresh_question_stats: (question_id)->
            question = Docs.findOne question_id
            # console.log question
            reservations = Docs.find({model:'reservation', question_id:question_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_question_hours = 0
            average_question_duration = 0

            # shorquestion_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_question_hours += parseFloat(res.hour_duration)

            average_question_cost = total_earnings/reservation_count
            average_question_duration = total_question_hours/reservation_count

            Docs.update question_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_question_hours: total_question_hours.toFixed(0)
                    average_question_cost: average_question_cost.toFixed(0)
                    average_question_duration: average_question_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header question ranking #reservations
            # .ui.small.header question ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg question time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
