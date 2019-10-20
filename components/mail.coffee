if Meteor.isClient
    Router.route '/messages/', (->
        @layout 'layout'
        @render 'messages'
        ), name:'messages'

    Template.messages.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'messages'

    Template.messages.helpers
        messagess: ->
            Docs.find
                model:'messages'
    Template.messages.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'messages'
                message:message
