if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'
    Router.route '/shop/:doc_id/edit', (->
        @layout 'layout'
        @render 'shop_edit'
        ), name:'shop_edit'
    Router.route '/shop/:doc_id/view', (->
        @layout 'layout'
        @render 'shop_view'
        ), name:'shop_view'



    Template.shop_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.shop_edit.events
        'click .add_shop_item': ->
            new_mi_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{_id}/edit"


    Template.shop_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.shop_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.shop.onRendered ->
        Session.setDefault 'view_mode', 'cards'
    Template.shop.helpers
        viewing_cards: -> Session.equals 'view_mode', 'cards'
        viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.shop.events
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

    Template.shop_stats.events
        'click .refresh_shop_stats': ->
            Meteor.call 'refresh_shop_stats', @_id




if Meteor.isServer
    Meteor.publish 'shop_reservations_by_id', (shop_id)->
        Docs.find
            model:'reservation'
            shop_id: shop_id

    Meteor.publish 'shops', (product_id)->
        Docs.find
            model:'shop'
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
        shops_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            shops.return.push date_string
        shops_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_shop_stats: (shop_id)->
            shop = Docs.findOne shop_id
            # console.log shop
            reservations = Docs.find({model:'reservation', shop_id:shop_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_shop_hours = 0
            average_shop_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_shop_hours += parseFloat(res.hour_duration)

            average_shop_cost = total_earnings/reservation_count
            average_shop_duration = total_shop_hours/reservation_count

            Docs.update shop_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_shop_hours: total_shop_hours.toFixed(0)
                    average_shop_cost: average_shop_cost.toFixed(0)
                    average_shop_duration: average_shop_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header shop ranking #reservations
            # .ui.small.header shop ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg shop time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
