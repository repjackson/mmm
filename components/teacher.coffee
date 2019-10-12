if Meteor.isClient
    Router.route '/teachers/', (->
        @layout 'layout'
        @render 'teachers'
        ), name:'teachers'
    Router.route '/teacher/:doc_id/edit', (->
        @layout 'layout'
        @render 'teacher_edit'
        ), name:'teacher_edit'
    Router.route '/teacher/:doc_id/view', (->
        @layout 'layout'
        @render 'teacher_view'
        ), name:'teacher_view'



    Template.teacher_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.teacher_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.teacher_edit.events
        'click .add_shop_item': ->
            new_shop_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{new_shop_id}/edit"



    Template.teacher_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.teacher_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.teachers.onRendered ->
        Session.setDefault 'view_mode', 'cards'
    Template.teachers.helpers
        viewing_cards: -> Session.equals 'view_mode', 'cards'
        viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.teachers.events
        'click .set_card_view': ->
            Session.set 'view_mode', 'cards'
        'click .set_segment_view': ->
            Session.set 'view_mode', 'segments'




if Meteor.isServer
    Meteor.publish 'teacher_reservations_by_id', (teacher_id)->
        Docs.find
            model:'reservation'
            teacher_id: teacher_id

    Meteor.publish 'teachers', (product_id)->
        Docs.find
            model:'teacher'
            product_id:product_id



    Meteor.methods
        refresh_teacher_stats: (teacher_id)->
            teacher = Docs.findOne teacher_id
            # console.log teacher
            reservations = Docs.find({model:'reservation', teacher_id:teacher_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_teacher_hours = 0
            average_teacher_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_teacher_hours += parseFloat(res.hour_duration)

            average_teacher_cost = total_earnings/reservation_count
            average_teacher_duration = total_teacher_hours/reservation_count

            Docs.update teacher_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_teacher_hours: total_teacher_hours.toFixed(0)
                    average_teacher_cost: average_teacher_cost.toFixed(0)
                    average_teacher_duration: average_teacher_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header teacher ranking #reservations
            # .ui.small.header teacher ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg teacher time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
