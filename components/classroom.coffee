if Meteor.isClient
    Router.route '/classrooms', -> @render 'classrooms'
    Router.route '/classroom/:doc_id/view', (->
        @layout 'layout'
        @render 'classroom_view'
        ), name:'classroom_view'
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

    Template.classroom_edit.events
        'click .add_shop_item': ->
            new_shop_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{new_shop_id}/edit"


    Template.classroom_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.classroom_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
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


    #     'click .calculate_diff': ->
    #         product = Template.parentData()
    #         console.log product
    #         moment_a = moment @start_datetime
    #         moment_b = moment @end_datetime
    #         reservation_hours = -1*moment_a.diff(moment_b,'hours')
    #         reservation_days = -1*moment_a.diff(moment_b,'days')
    #         hourly_reservation_price = reservation_hours*product.hourly_rate
    #         daily_reservation_price = reservation_days*product.daily_rate
    #         Docs.update @_id,
    #             $set:
    #                 reservation_hours:reservation_hours
    #                 reservation_days:reservation_days
    #                 hourly_reservation_price:hourly_reservation_price
    #                 daily_reservation_price:daily_reservation_price

    Template.classroom_stats.events
        'click .refresh_classroom_stats': ->
            Meteor.call 'refresh_classroom_stats', @_id




if Meteor.isServer
    Meteor.publish 'classroom_reservations_by_id', (classroom_id)->
        Docs.find
            model:'reservation'
            classroom_id: classroom_id

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
