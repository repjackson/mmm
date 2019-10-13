if Meteor.isClient
    Router.route '/classrooms', ->
        @render 'classrooms'
    Router.route '/classroom/:doc_id/view', (->
        @layout 'layout'
        @render 'classroom_view'
        ), name:'classroom_view'
    Router.route '/classroom/:doc_id/dashboard', (->
        @layout 'layout'
        @render 'classroom_dashboard'
        ), name:'classroom_dashboard'
    Router.route '/classroom/:doc_id/reports', (->
        @layout 'layout'
        @render 'classroom_reports'
        ), name:'classroom_reports'
    Router.route '/classroom/:doc_id/edit', (->
        @layout 'layout'
        @render 'classroom_edit'
        ), name:'classroom_edit'


    Template.classroom_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.classroom_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.classroom_edit.helpers
        features: ->
            Docs.find
                model:'feature'
        feature_edit_template: ->
            "#{@title}_edit_template"

        toggle_feature_class: ->
            classroom = Docs.findOne Router.current().params.doc_id
            if classroom.feature_ids and @_id in classroom.feature_ids then 'blue' else ''

        selected_features: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: classroom.feature_ids
                model:'feature'
            ).fetch()
    Template.classroom_edit.events
        'click .toggle_feature': ->
            classroom = Docs.findOne Router.current().params.doc_id
            if classroom.feature_ids and @_id in classroom.feature_ids
                Docs.update Router.current().params.doc_id,
                    $pull: feature_ids: @_id
            else
                Docs.update Router.current().params.doc_id,
                    $addToSet: feature_ids: @_id
        'click .add_shop_item': ->
            new_shop_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{new_shop_id}/edit"

    Template.classroom_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
    Template.classroom_dashboard.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700

    Template.classroom_dashboard.helpers
        classroom_students: ->
            Meteor.users.find()
    Template.classroom_dashboard.events
        'change .date_select': ->
            console.log $('.date_select').val()
        'click .add_credit': (e,t)->
            console.log @
            Meteor.users.update @_id,
                $inc:credit:2
            $(e.currentTarget).closest('.credit_view').transition('pulse', 200)
        'click .remove_credit': (e,t)->
            Meteor.users.update @_id,
                $inc:credit:-2
            $(e.currentTarget).closest('.credit_view').transition('pulse', 200)






    Template.classroom_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.classroom_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.classroom_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.classroom_view.helpers
        features: ->
            Docs.find
                model:'feature'
        feature_view_template: ->
            "#{@title}_view_template"

        selected_features: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: classroom.feature_ids
                model:'feature'
            ).fetch()




    Template.class_feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'feed'
    Template.class_feed.helpers
        class_feed_items: ->
            Docs.find
                model:'feed'






    Template.classrooms.onRendered ->
        Session.setDefault 'view_mode', 'cards'
    Template.classrooms.helpers
        viewing_cards: -> Session.equals 'view_mode', 'cards'
        viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.classrooms.events
        'click .set_card_view': ->
            Session.set 'view_mode', 'cards'
        'click .set_segment_view': ->
            Session.set 'view_mode', 'segments'

    Template.classroom_stats.events
        'click .refresh_classroom_stats': ->
            Meteor.call 'refresh_classroom_stats', @_id




if Meteor.isServer
    Meteor.publish 'classroom_students', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            username: $in: classroom.students

    Meteor.publish 'classrooms', (product_id)->
        Docs.find
            model:'classroom'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        classrooms_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            classrooms.return.push date_string
        classrooms_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_classroom_stats: (classroom_id)->
            classroom = Docs.findOne classroom_id
            # console.log classroom
            reservations = Docs.find({model:'reservation', classroom_id:classroom_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_classroom_hours = 0
            average_classroom_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_classroom_hours += parseFloat(res.hour_duration)

            average_classroom_cost = total_earnings/reservation_count
            average_classroom_duration = total_classroom_hours/reservation_count

            Docs.update classroom_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_classroom_hours: total_classroom_hours.toFixed(0)
                    average_classroom_cost: average_classroom_cost.toFixed(0)
                    average_classroom_duration: average_classroom_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header classroom ranking #reservations
            # .ui.small.header classroom ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg classroom time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
