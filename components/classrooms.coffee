if Meteor.isClient
    Template.classrooms.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom'
    Template.classrooms.events
        'click .add_classroom': ->
            new_classroom = Docs.insert
                model:'classroom'
            Router.go "/classroom/#{new_classroom}/edit"


    Template.classrooms.helpers
        classrooms: ->
            Docs.find {
                model:'classroom'
            }, sort: _timestamp: -1
