if Meteor.isClient
    Router.route '/compound/', (->
        @layout 'layout'
        @render 'compound'
        ), name:'compound'

    Template.compound.helpers

    Template.compound.events
        'click .start_donation': ->
