if Meteor.isClient
    Router.route '/rentals', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'rentals'


    Template.rentals.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'rental'
    Template.rentals.helpers
        rentals: ->
            Docs.find
                model:'rental'
    Template.rentals.events
        'click .add_rental': ->
            new_rental_id = Docs.insert
                model:'rental'
            Router.go "/rental/#{new_rental_id}/edit"




    # Template.rental_checkout.onRendered ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # Template.rental_checkout.helpers
    #     is_paying: -> Session.get 'paying'
    #     can_buy: -> Meteor.user().credit > @price
    #     need_credit: -> Meteor.user().credit < @price
    #     need_approval: -> @friends_only and Meteor.userId() not in @author.friend_ids
    #     submit_button_class: -> if @start_datetime and @end_datetime then '' else 'disabled'
    #     user_balance_after_reservation: ->
    #         rental = Docs.findOne @rental_id
    #         if rental
    #             current_balance = Meteor.user().credit
    #             (current_balance-@price).toFixed(2)
    #
    # Template.rental_checkout.events
    #     'click .buy_product': ->
    #         Router.go "/rental/#{@_id}/checkout"


    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




if Meteor.isServer
    Meteor.publish 'rental_reservations_by_id', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            reservations = Docs.find({model:'reservation', rental_id:rental_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/reservation_count
            average_rental_duration = total_rental_hours/reservation_count

            Docs.update rental_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header rental ranking #reservations
            # .ui.small.header rental ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg rental time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
