if Meteor.isClient
    Template.user_offers.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'user_offer'
    Template.user_offers.helpers
        available_offers: ->
            Docs.find
                model:'user_offer'
