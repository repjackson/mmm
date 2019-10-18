if Meteor.isClient
    Template.classrooms.onRendered ->
        # Session.setDefault 'view_mode', 'cards'
    Template.classrooms.helpers
        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.classrooms.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


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
