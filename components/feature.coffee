if Meteor.isClient
    Router.route '/features', (->
        @layout 'layout'
        @render 'features'
        ), name:'features'
    Router.route '/feature/:doc_id/edit', (->
        @layout 'layout'
        @render 'feature_edit'
        ), name:'feature_edit'
    Router.route '/feature/:doc_id/view', (->
        @layout 'layout'
        @render 'feature_view'
        ), name:'feature_view'



    Template.feature_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.feature_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.feature_edit.events
        'click .add_feature_item': ->
            new_mi_id = Docs.insert
                model:'feature_item'
            Router.go "/feature/#{_id}/edit"


    Template.feature_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.feature_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.features.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.features.helpers
        features: ->
            Docs.find
                model:'feature'
    Template.features.events
        'click .add_feature': ->
            new_feature_id = Docs.insert
                model:'feature'
            Router.go "/feature/#{new_feature_id}/edit"

    Template.feature_stats.events
        'click .refresh_feature_stats': ->
            Meteor.call 'refresh_feature_stats', @_id




if Meteor.isServer
    Meteor.publish 'features', (product_id)->
        Docs.find
            model:'feature'
            product_id:product_id

    Meteor.methods
        refresh_feature_stats: (feature_id)->
            feature = Docs.findOne feature_id
            # console.log feature
            reservations = Docs.find({model:'reservation', feature_id:feature_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_feature_hours = 0
            average_feature_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_feature_hours += parseFloat(res.hour_duration)

            average_feature_cost = total_earnings/reservation_count
            average_feature_duration = total_feature_hours/reservation_count

            Docs.update feature_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_feature_hours: total_feature_hours.toFixed(0)
                    average_feature_cost: average_feature_cost.toFixed(0)
                    average_feature_duration: average_feature_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header feature ranking #reservations
            # .ui.small.header feature ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg feature time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
