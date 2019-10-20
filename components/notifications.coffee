if Meteor.isClient
    Router.route '/notifications/', (->
        @layout 'layout'
        @render 'notifications'
        ), name:'notifications'

    Template.notifications.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'notifications'

    Template.notifications.helpers
        notificationss: ->
            Docs.find
                model:'notifications'
    Template.notifications.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'notifications'
                message:message
