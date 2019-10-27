if Meteor.isClient
    Template.user_offers.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'user_offer'
    Template.user_offers.helpers
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
    Template.user_offers.events
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

        'click .unaccept_offer': ->
            console.log @
            Docs.update @_id,
                $pull: accepted_user_ids: Meteor.userId()
