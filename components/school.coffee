if Meteor.isClient
    Router.route '/schools/', (->
        @layout 'layout'
        @render 'schools'
        ), name:'schools'
    Router.route '/school/:doc_id/edit', (->
        @layout 'layout'
        @render 'school_edit'
        ), name:'school_edit'
    Router.route '/school/:doc_id/view', (->
        @layout 'layout'
        @render 'school_view'
        ), name:'school_view'



    Template.school_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.school_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.school_edit.events
        'click .add_shop_item': ->
            new_shop_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{new_shop_id}/edit"



    Template.school_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.school_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.schools.onRendered ->
        Session.setDefault 'view_mode', 'cards'
    Template.schools.helpers
        viewing_cards: -> Session.equals 'view_mode', 'cards'
        viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.schools.events
        'click .set_card_view': ->
            Session.set 'view_mode', 'cards'
        'click .set_segment_view': ->
            Session.set 'view_mode', 'segments'




if Meteor.isServer
    Meteor.publish 'school_reservations_by_id', (school_id)->
        Docs.find
            model:'reservation'
            school_id: school_id

    Meteor.publish 'schools', (product_id)->
        Docs.find
            model:'school'
            product_id:product_id



    Meteor.methods
        refresh_school_stats: (school_id)->
            school = Docs.findOne school_id
            # console.log school
            reservations = Docs.find({model:'reservation', school_id:school_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_school_hours = 0
            average_school_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_school_hours += parseFloat(res.hour_duration)

            average_school_cost = total_earnings/reservation_count
            average_school_duration = total_school_hours/reservation_count

            Docs.update school_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_school_hours: total_school_hours.toFixed(0)
                    average_school_cost: average_school_cost.toFixed(0)
                    average_school_duration: average_school_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header school ranking #reservations
            # .ui.small.header school ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg school time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
