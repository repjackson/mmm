if Meteor.isClient
    Template.classrooms.onRendered ->
    Template.classrooms.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom'
    Template.classrooms.events
        'click .add_classroom': ->
            new_classroom = Docs.insert
                model:'classroom'
                teacher_id: Meteor.userId()
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/classroom/#{new_classroom}/edit"
    Template.classrooms.helpers
        classrooms: ->
            Docs.find {
                model:'classroom'
            }, sort: _timestamp: -1


    Template.my_classrooms.onRendered ->
    Template.my_classrooms.onCreated ->
        @autorun => Meteor.subscribe 'my_classrooms'
    Template.my_classrooms.events
        'click .add_classroom': ->
            new_classroom = Docs.insert
                model:'classroom'
                teacher_id: Meteor.userId()
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/classroom/#{new_classroom}/edit"
    Template.my_classrooms.helpers
        classrooms: ->
            Docs.find {
                model:'classroom'
            }, sort: _timestamp: -1

if Meteor.isServer
    Meteor.publish 'my_classrooms', ->
        Docs.find
            model:'classroom'
            teacher_id:Meteor.userId()
