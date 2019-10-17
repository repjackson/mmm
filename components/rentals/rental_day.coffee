if Meteor.isClient
    Template.rental_day.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'reservations', Router.current().params.doc_id,Router.current().params.month,Router.current().params.day,Router.current().params.year

    Template.rental_day.helpers
        rental:->
            Docs.findOne Router.current().params.doc_id

        hours: -> [7..17]
        month:-> Router.current().params.month
        day:-> Router.current().params.day
        year:-> Router.current().params.year

        reservations:->
            rental = Docs.findOne Router.current().params.doc_id
            month = Router.current().params.month
            day = Router.current().params.day
            year = Router.current().params.year
            Docs.find
                model:'reservation'
                rental_id_id:rental._id
                date:"#{month}-#{day}-#{year}"

        reservation_exists:->
            rental = Docs.findOne Router.current().params.doc_id
            month = Router.current().params.month
            day = Router.current().params.day
            year = Router.current().params.year
            Docs.findOne
                model:'reservation'
                rental_id_id:rental._id
                date:"#{month}-#{day}-#{year}"
                hour:parseInt(@)

        reservation_rental:->
            slot = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'shop'
                # _id:slot.doc_id



    Template.rental_day.events
        'click .confirm_delivery': ->
            if confirm 'confirm delivery?'
                # console.log 'your credits', Meteor.user().credits
                # console.log 'seller credits', Meteor.users.findOne(@_author_id)
                Docs.update @_id,
                    $set:
                        confirmed:true

        'click .cancel_reservation': ->
            Docs.update @_id,
                $set:
                    confirmed:false

        'click .mark_delivery_started': ->
            if confirm 'mark delivery started?'
                Docs.update @_id,
                    $set:
                        delivery_started_timestamp:Date.now()
                        status:'delivery started'
                        delivery_started:true

        'click .new_reservation': ->
            rental = Docs.findOne Router.current().params.doc_id
            month = Router.current().params.month
            day = Router.current().params.day
            year = Router.current().params.year
            # console.log @
            Docs.insert
                model:'reservation'
                rental_id_id:rental._id
                date:"#{month}-#{day}-#{year}"
                hour:parseInt(@)
            # console.log Template.parentData()

        'click .mark_delivered': ->
            console.log @
            if confirm 'mark delivery ended?'
                Docs.update @_id,
                    $set:
                        delivery_ended_timestamp:Date.now()
                        status:'delivery ended'
                        delivery_ended:true

        'click .mark_complete': ->
            if confirm 'mark reservation ended?'
                Docs.update @_id,
                    $set:
                        reservation_ended_timestamp:Date.now()
                        status:'reservation marked complete'
                        reservation_ended:true


    Template.reservation_rental_template.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.reservation_rental_template.helpers
        s: ->
            console.log @
        reservation_rental:->
            Docs.findOne Router.current().params.doc_id

if Meteor.isServer
    Meteor.publish 'reservations', (doc_id, month, day, year)->
        rental = Docs.findOne doc_id
        console.log month
        console.log day
        console.log year
        Docs.find
            model:'reservation'
            doc_id:doc_id
            date:"#{month}-#{day}-#{year}"

    # Meteor.publish 'reservation_slot_reservation', (slot_id)->
    #     slot = Docs.findOne slot_id
    #     console.log 'slot', slot
    #     res = Docs.find(
    #         model:'reservation'
    #         parent_slot:slot._id
    #         )
    #     console.log res.fetch()
    #     return res
