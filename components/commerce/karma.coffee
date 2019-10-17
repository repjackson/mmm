if Meteor.isClient
    Router.route '/karma', -> @render 'karma'
    Router.route '/new_karma_transaction/:doc_id', -> @render 'new_karma_transaction'
    Router.route '/view_karma_transaction/:doc_id', -> @render 'view_karma_transaction'

    Template.karma.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        @autorun -> Meteor.subscribe 'my_karma_sent'
        @autorun -> Meteor.subscribe 'my_karma_received'
        # @autorun -> Meteor.subscribe 'shop'

    Template.karma.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.karma.events
        'click .checkout_karma': ->
            if confirm 'complete checkout?'
                karma_items = Docs.find(model:'karma_item').fetch()
                for karma_item in karma_items
                    referenced_product =
                        Docs.findOne
                            _id:karma_item.product_id
                    Meteor.users.update Meteor.userId(),
                        $inc:karma:-referenced_product.karma_price
                    # total_karma_cost += referenced_product.karma_price
                    Docs.insert
                        model:'transaction'
                        product_id:referenced_product._id
                        purchase_price:referenced_product.karma_price
                        user_karma_before:Meteor.user().karma
                        user_karma_after:Meteor.user().karma-referenced_product.karma_price
                $('.karma_item').transition(
                    animation: 'fly right'
                    duration: 1000
                    interval: 200
                    onComplete: ()=>
                        for karma_item in karma_items
                            Docs.remove karma_item._id
                        Router.go '/transactions'
                )



    Template.karma.helpers
        karma_received: ->
            Docs.find
                model:'karma_transaction'
                to_username: Meteor.user().username
        karma_sent: ->
            Docs.find
                model:'karma_transaction'
                from_username: Meteor.user().username
        karma_items: ->
            Docs.find
                model:'karma_item'
        total_karma_cost: ->
            total_karma_cost = 0
            karma_items = Docs.find(model:'karma_item').fetch()
            for karma_item in karma_items
                referenced_product =
                    Docs.findOne
                        _id:karma_item.product_id
                total_karma_cost += referenced_product.karma_price
            total_karma_cost
        can_buy: ->
            total_karma_cost = 0
            karma_items = Docs.find(model:'karma_item').fetch()
            for karma_item in karma_items
                referenced_product =
                    Docs.findOne
                        _id:karma_item.product_id
                total_karma_cost += referenced_product.karma_price
            total_karma_cost < Meteor.user().karma





    Template.earning_methods_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'earning_opportunity'
    Template.earning_methods_small.helpers
        opportunities: ->
            Docs.find {
                model:'earning_opportunity'
            }, sort:_timestamp:-1




    Template.received_karma.onCreated ->
        @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.received_karma.helpers
        received_karma: ->
            Docs.find
                model:'karma_transaction'
                to_username:Router.current().params.username
                # confirmed:true


    Template.sent_karma.onCreated ->
        @autorun => Meteor.subscribe 'username_sent_karma', Router.current().params.username
    Template.sent_karma.helpers
        sent: ->
            Docs.find
                model:'karma_transaction'
                from_username:Router.current().params.username
                # confirmed:true



    Template.new_karma_transaction.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.view_karma_transaction.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.new_karma_transaction.helpers
    Template.new_karma_transaction.events
        'click .uncomplete': (e,t)->
            transaction = Docs.findOne Router.current().params.doc_id
            Docs.update transaction._id,
                $set:
                    complete: false

        'click .complete_transaction': (e,t)->
            if confirm 'confirm transaction?'
                transaction = Docs.findOne Router.current().params.doc_id
                # Session.set 'taking', true
                # Meteor.setTimeout ->
                #     t.$(e.currentTarget).closest('.my_karma_amount').addClass('spinning')
                # , 3000
                # Session.set 'taking', false
                # Session.set 'giving', true
                # Meteor.setTimeout ->
                # , 3000
                # Session.set 'giving', false
                # Session.set 'complete', true
                # t.$(e.currentTarget).closest('.my_karma_amount').addClass('spinning')
                Meteor.users.update transaction.from_user_id,
                    $inc:karma:-transaction.karma_amount
                Meteor.users.update transaction.to_user_id,
                    $inc:karma:transaction.karma_amount
                Docs.update transaction._id,
                    $set:
                        complete: true
                        completed_timestamp: Date.now()
                Router.go "/view_karma_transaction/#{transaction._id}"



    Template.karma_transactions_small.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'karma_transaction'
    Template.karma_transactions_small.helpers
        transactions: ->
            Docs.find {
                model:'karma_transaction'
            },
                sort:_timestamp:-1
                limit: 5




    Template.send_user_karma.events
        'click .send_karma': ->
            console.log @
            new_transaction_id = Docs.insert
                model: 'karma_transaction'
                from_user_id: Meteor.userId()
                to_user_id: @_id
                from_username: Meteor.user().username
                to_username: @username
            Router.go "/new_karma_transaction/#{new_transaction_id}"



if Meteor.isServer
    Meteor.publish 'user_confirmed_transactions', (username)->
        Docs.find
            model:'karma_transaction'
            to_username:username
            # confirmed:true

    Meteor.publish 'username_sent_karma', (username)->
        Docs.find
            model:'karma_transaction'
            from_username:username
            # confirmed:true

    Meteor.publish 'my_karma_received', ->
        Docs.find
            model:'karma_transaction'
            to_username:Meteor.user().username
            # confirmed:true
    Meteor.publish 'my_karma_sent', ->
        Docs.find
            model:'karma_transaction'
            from_username:Meteor.user().username
            # confirmed:true
