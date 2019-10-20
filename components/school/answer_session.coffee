if Meteor.isClient
    Router.route '/answer_sessions', (->
        @layout 'layout'
        @render 'answer_sessions'
        ), name:'answer_sessions'
    Router.route '/answer_session/:doc_id/edit', (->
        @layout 'layout'
        @render 'answer_session_edit'
        ), name:'answer_session_edit'
    Router.route '/answer_session/:doc_id/view', (->
        @layout 'layout'
        @render 'answer_session_view'
        ), name:'answer_session_view'



    Template.answer_session_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.answer_session_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_from_answer_session', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_choices_from_answer_session_id', Router.current().params.doc_id
    Template.answer_session_edit.events
        'click .select_choice': ->
            console.log @
            Docs.update Router.current().params.doc_id,
                $set: choice_selection_id: @_id
    Template.answer_session_edit.helpers
        choice_seleect_class: ->
            answer_session = Docs.findOne Router.current().params.doc_id
            if answer_session.choice_selection_id is @_id then 'active' else ''
        parent_question: ->
            answer_session = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'question'
                _id:answer_session.question_id
        choices: ->
            Docs.find
                model:'choice'
        has_selected: ->
            answer_session = Docs.findOne Router.current().params.doc_id
            answer_session.choice_selection_id


    Template.answer_session_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'bounty'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.answer_session_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.answer_session_view.helpers
        choices: ->
            Docs.find
                model:'choice'
        bounties: ->
            Docs.find
                model:'bounty'
                answer_session_id:@_id
    Template.answer_session_view.events
        'click .new_answer_session': ->
            # console.log @
            Docs.insert
                model:'answer_session'
                answer_session_id: Router.current().params.doc_id
        'click .offer_bounty': ->
            console.log @
            new_bounty_id = Docs.insert
                model:'bounty'
                answer_session_id:@_id
            Router.go "/bounty/#{new_bounty_id}/edit"





    Template.answer_sessions.onRendered ->
        # @autorun => Meteor.subscribe 'model_docs', 'answer_session'
    Template.answer_sessions.helpers
        answer_sessions: ->
            Docs.find
                model:'answer_session'



    Template.answer_sessions.events
        'click .add_answer_session': ->
            new_answer_session_id = Docs.insert
                model:'answer_session'
            Router.go "/answer_session/#{new_answer_session_id}/edit"



    Template.answer_session_stats.events
        'click .refresh_answer_session_stats': ->
            Meteor.call 'refresh_answer_session_stats', @_id




if Meteor.isServer
    Meteor.publish 'answer_sessions', (product_id)->
        Docs.find
            model:'answer_session'
            product_id:product_id

    Meteor.publish 'question_from_answer_session', (answer_session_id)->
        answer_session = Docs.findOne answer_session_id
        Docs.find
            model:'question'
            _id:answer_session.question_id

    Meteor.publish 'question_choices_from_answer_session_id', (answer_session_id)->
        answer_session = Docs.findOne answer_session_id
        question = Docs.findOne
            model:'question'
            _id:answer_session.question_id
        Docs.find
            model:'choice'
            question_id: question._id



    Meteor.methods
        refresh_answer_session_stats: (answer_session_id)->
            answer_session = Docs.findOne answer_session_id
            # console.log answer_session
            reservations = Docs.find({model:'reservation', answer_session_id:answer_session_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_answer_session_hours = 0
            average_answer_session_duration = 0

            # shoranswer_session_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_answer_session_hours += parseFloat(res.hour_duration)

            average_answer_session_cost = total_earnings/reservation_count
            average_answer_session_duration = total_answer_session_hours/reservation_count

            Docs.update answer_session_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_answer_session_hours: total_answer_session_hours.toFixed(0)
                    average_answer_session_cost: average_answer_session_cost.toFixed(0)
                    average_answer_session_duration: average_answer_session_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header answer_session ranking #reservations
            # .ui.small.header answer_session ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg answer_session time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
