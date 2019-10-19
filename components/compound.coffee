if Meteor.isClient
    Router.route '/compound', (->
        @layout 'layout'
        @render 'compound'
        ), name:'compound'

    Template.compound.onCreated ->
        Session.setDefault 'amount', 0
    Template.compound.helpers
        amount: -> Session.get 'amount'
        interest_rate: -> Session.get 'interest_rate'
        compoundings_per_period: -> Session.get 'compoundings_per_period'
        number_of_periods: -> Session.get 'number_of_periods'
        principal: -> Session.get 'principal'
        compound_result: ->
            console.log @
    Template.compound.events
        'click .start_donation': ->

if Meteor.isServer
    Meteor.methods
        calc_compound_interest:(amount, interest_rate, compoundings_per_period, number_of_periods, principal)->
            A = amount
            r = interest_rate
            n = compoundings_per_period
            t = number_of_periods
            A = P*(1+(r/n))^(n*t)
            console.log A
