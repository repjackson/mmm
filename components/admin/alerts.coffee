if Meteor.isClient
    Router.route '/alerts/', (->
        @layout 'layout'
        @render 'alerts'
        ), name:'alerts'

    Template.alerts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'alerts'

    Template.alerts.helpers
        alerts: ->
            Docs.find
                model:'alerts'
    Template.alerts.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'alerts'
                message:message
