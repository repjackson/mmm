if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'home_stats'
        @autorun -> Meteor.subscribe 'model_docs', 'sponsor'
    Template.home.onRendered ->
        Meteor.setTimeout ->
            $('.ui.sidebar')
                .sidebar('attach events', '.toc.item')
        ,500
        # if Meteor.isProduction
        Meteor.call 'increment_home_view', ->

    Template.home.helpers
        hs: ->
            Docs.findOne
                model:'home_stats'
        home_sponsor: ->
            Docs.findOne
                model:'sponsor'
    Template.home.events
        'click .recalc_stats': ->
            Meteor.call 'calc_home_stats', ->



if Meteor.isServer
    Meteor.methods
        increment_home_view: ->
            hs = Docs.findOne
                model:'home_stats'
            Docs.update hs._id,
                $inc: homepage_views: 1

        calc_home_stats: ->
            hs = Docs.findOne
                model:'home_stats'
            unless hs
                new_stats = Docs.insert
                    model:'home_stats'
                hs = Docs.findOne new_stats
            user_count = Meteor.users.find().count()
            leader_count = Meteor.users.find(roles:$in:['leader']).count()
            donor_count = Meteor.users.find(roles:$in:['donor']).count()
            group_count =
                Docs.find(
                    model:'group'
                ).count()
            donations_count =
                Docs.find(
                    model:'donation'
                ).count()
            credit_count =
                Docs.find(
                    model:'credit_type'
                ).count()
            offer_count =
                Docs.find(
                    model:'user_offer'
                ).count()
            debit_count =
                Docs.find(
                    model:'debit_type'
                ).count()
            product_count =
                Docs.find(
                    model:'shop'
                ).count()
            Docs.update hs._id,
                $set:
                    user_count:user_count
                    leader_count:leader_count
                    donor_count:donor_count
                    offer_count:offer_count
                    group_count:group_count
                    credit_count:credit_count
                    debit_count:debit_count
                    donations_count:donations_count
                    product_count:product_count
