if Meteor.isClient
    Template.inbox.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'message'
    Template.inbox.helpers
        messages: ->
            Docs.find {
                model:'message'
            }, sort: _timestamp: -1



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id
