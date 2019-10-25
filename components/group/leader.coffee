if Meteor.isClient
    Router.route '/leaders/', (->
        @layout 'layout'
        @render 'leaders'
        ), name:'leaders'
    Router.route '/leader/:doc_id/edit', (->
        @layout 'layout'
        @render 'leader_edit'
        ), name:'leader_edit'
    Router.route '/leader/:doc_id/view', (->
        @layout 'layout'
        @render 'leader_view'
        ), name:'leader_view'



    # Template.leader_edit.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000
    #
    #
    # Template.leader_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    #
    # Template.leader_edit.events
    #     'click .add_shop_item': ->
    #         new_shop_id = Docs.insert
    #             model:'shop_item'
    #         Router.go "/shop/#{new_shop_id}/edit"



    Template.leader_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.leader_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.leaders.onRendered ->
        Session.setDefault 'view_mode', 'cards'
    Template.leaders.helpers
        viewing_cards: -> Session.equals 'view_mode', 'cards'
        viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.leaders.events
        'click .set_card_view': ->
            Session.set 'view_mode', 'cards'
        'click .set_segment_view': ->
            Session.set 'view_mode', 'segments'



    Template.leader_selector.onCreated ->
        @leader_results = new ReactiveVar
    Template.leader_selector.helpers
        leader_results: -> Template.instance().leader_results.get()
    Template.leader_selector.events
        'click .clear_results': (e,t)->
            t.leader_results.set null

        'keyup #leader_lookup': (e,t)->
            search_value = $(e.currentTarget).closest('#leader_lookup').val().trim()
            if search_value.length > 1
                Meteor.call 'lookup_leader', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.leader_results.set res

        'click .select_leader': (e,t) ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.update group._id,
                $set:leader_id:@_id
            t.leader_results.set null
            $('#leader_lookup').val ''

        'click .clear_leader': ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.update group._id,
                $unset:leader_id:1


    Template.leader_card.onCreated ->
        @autorun => Meteor.subscribe 'user_by_id', @data
    Template.leader_card.helpers
        leader: -> Meteor.users.findOne Template.currentData()




if Meteor.isServer
    Meteor.publish 'leader_reservations_by_id', (leader_id)->
        Docs.find
            model:'reservation'
            leader_id: leader_id

    Meteor.publish 'leaders', (product_id)->
        Docs.find
            model:'leader'
            product_id:product_id



    Meteor.methods
        lookup_leader: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['leaders']
                },{limit:10}).fetch()

        refresh_leader_stats: (leader_id)->
            leader = Docs.findOne leader_id
            # console.log leader
            reservations = Docs.find({model:'reservation', leader_id:leader_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_leader_hours = 0
            average_leader_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_leader_hours += parseFloat(res.hour_duration)

            average_leader_cost = total_earnings/reservation_count
            average_leader_duration = total_leader_hours/reservation_count

            Docs.update leader_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_leader_hours: total_leader_hours.toFixed(0)
                    average_leader_cost: average_leader_cost.toFixed(0)
                    average_leader_duration: average_leader_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header leader ranking #reservations
            # .ui.small.header leader ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg leader time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
