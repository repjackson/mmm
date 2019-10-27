if Meteor.isClient
    Router.route '/offers/', (->
        @layout 'layout'
        @render 'offers'
        ), name:'offers'

    Template.offers.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'user_offer'
    Template.offers.helpers
        available_offers: ->
            Docs.find
                model:'user_offer'
                rejected_user_ids: $nin: [Meteor.userId()]
                accepted_user_ids: $nin: [Meteor.userId()]
                completed_user_ids: $nin: [Meteor.userId()]
        rejected_offers: ->
            Docs.find
                model:'user_offer'
                rejected_user_ids: $in: [Meteor.userId()]
        accepted_offers: ->
            Docs.find
                model:'user_offer'
                accepted_user_ids: $in: [Meteor.userId()]
        completed_offers: ->
            Docs.find
                model:'user_offer'
                completed_user_ids: $in: [Meteor.userId()]


    Template.offers.events
        'click .accept_offer': ->
            console.log @
            Docs.update @_id,
                $addToSet: accepted_user_ids: Meteor.userId()

        'click .reject_offer': ->
            console.log @
            Docs.update @_id,
                $addToSet: rejected_user_ids: Meteor.userId()

        'click .unreject_offer': ->
            console.log @
            Docs.update @_id,
                $pull: rejected_user_ids: Meteor.userId()



    Template.accepted_offer.events
        'click .unaccept_offer': ->
            console.log @
            Docs.update @_id,
                $pull: accepted_user_ids: Meteor.userId()

        'click .check_completion': ->
            console.log @
            Meteor.call 'check_offer', @_id, Meteor.userId(), ->


if Meteor.isServer
    Meteor.methods
        check_offer: (offer_id, user_id)->
            offer = Docs.findOne offer_id
            user = Meteor.users.findOne user_id
            console.log 'checking offer', offer.slug
            Meteor.call "check_#{offer.slug}", user_id, (err,res)=>
                console.log 'check res', res
                if res is true
                    Docs.insert
                        model:'log_event'
                        event_type:'offer completion'
                        referenced_doc_id:offer_id
                        referenced_user_id:user_id
                        text: "offer #{offer.title} was completed by #{user.name}"
                    Docs.update offer._id,
                        $addToSet: completed_user_ids: user_id
                        $pull: accepted_user_ids: user_id
                    Docs.insert
                        model:'credit_transaction'
                        recipient_id: user_id
                        credit_amount: offer.credit_amount
                        text: "#{offer.credit_amount} was sent to #{user.username} for completing #{offer.title}"
                    Meteor.users.update user_id,
                        $inc: credit: offer.credit_amount


        check_profile_image: (user_id)->
            user = Meteor.users.findOne user_id
            console.log 'checking profile image on ', user.username
            if user.profile_image_id then true else false
        check_name: (user_id)->
            user = Meteor.users.findOne user_id
            console.log 'checking name on ', user.username
            if user.first_name and user.last_name then true else false
