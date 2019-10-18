if Meteor.isClient
    Template.user_wall.onCreated ->
        @autorun => Meteor.subscribe 'wall_posts', Router.current().params.username
    Template.user_wall.helpers
        wall_posts: ->
            Docs.find
                model:'wall_post'
    Template.user_wall.events
        'keyup .new_post': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if e.which is 13
                post = t.$('.new_post').val().trim()
                Docs.insert
                    body:post
                    model:'wall_post'
                    user_id:current_user._id
                t.$('.new_post').val('')
        'click .remove_comment': ->
            if confirm 'remove comment?'
                Docs.remove @_id
        'click .vote_up_comment': ->
            if @upvoters and Meteor.userId() in @upvoters
                Docs.update @_id,
                    $inc:points:1
                    $addToSet:upvoters:Meteor.userId()
                Meteor.users.update @author_id,
                    $inc:points:-1
            else
                Meteor.users.update @author_id,
                    $pull:upvoters:Meteor.userId()
                    $inc:points:1
                Meteor.users.update @author_id,
                    $inc:points:1

        'click .mark_comment_read': ->
            Docs.update @_id,
                $addToSet:readers:Meteor.userId()


    Template.user_bookmarks.onCreated ->
        @autorun => Meteor.subscribe 'user_bookmarks', Router.current().params.username
    Template.user_bookmarks.helpers
        bookmarks: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                bookmark_ids:$in:[current_user._id]
            }, sort:_timestamp:-1






    Template.user_transactions.onCreated ->
        @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.user_transactions.helpers
        user_transactions: ->
            Docs.find
                model:'karma_transaction'
                recipient:Router.current().params.username
                # confirmed:true





    Template.user_loans.onCreated ->
        @autorun => Meteor.subscribe 'user_docs', Router.current().params.username, 'loan'
    Template.user_loans.helpers
        user_loans: ->
            Docs.find
                model:'loan'
                _author_username:Router.current().params.username
    Template.user_loans.events
        'click .apply': ->
            console.log @
            new_loan_id = Docs.insert
                model:'loan'
                approved:false
            Router.go "/loan/#{new_loan_id}/edit"




    Template.user_connect_button.onCreated ->
        # @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.user_connect_button.helpers
        connected: ->
            Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
    Template.user_connect_button.events
        'click .toggle_connection': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse', 200)

            if Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
                Meteor.users.update Meteor.userId(),
                    $pull: connected_ids: @_id
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: connected_ids: @_id




    Template.user_tags.onCreated ->
        @autorun => Meteor.subscribe 'user_tag_reviews', Router.current().params.username
    Template.user_tags.helpers
        user_tag_reviews: ->
            Docs.find
                model:'user_tag_review'
        my_tag_review: ->
            Docs.findOne
                model:'user_tag_review'
                _author_id: Meteor.userId()





    Template.user_tags.events
        'click .new_tag_review': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.insert
                model:'user_tag_review'
                user_id:current_user._id


    Template.user_connections.onCreated ->
        @autorun => Meteor.subscribe 'user_connected_to', Router.current().params.username
        @autorun => Meteor.subscribe 'user_connected_by', Router.current().params.username
    Template.user_connections.helpers
        connected_to: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.connected_ids
                Meteor.users.find
                    _id:$in:current_user.connected_ids
        connected_by: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                connected_ids:$in:[current_user._id]



    Template.user_reservations.onCreated ->
        @autorun => Meteor.subscribe 'user_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'rental'
    Template.user_reservations.helpers
        reservations: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1


    Template.user_bids.onCreated ->
        @autorun => Meteor.subscribe 'user_bids', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'rental'
    Template.user_bids.helpers
        bids: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'bid'
            }, sort:_timestamp:-1




    Template.user_finance.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount*1.02+20
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'deposit'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100
    	)


    Template.user_finance.events
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: calculated_amount

        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount



    Template.user_finance.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'wall_posts', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'wall_post'
            user_id: current_user._id

    Meteor.publish 'user_tag_reviews', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'user_tag_review'
            user_id: current_user._id

    Meteor.publish 'user_docs', (username, model)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:model
            _author_id: current_user._id
