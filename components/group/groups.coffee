if Meteor.isClient
    Template.groups.onRendered ->
    Template.groups.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group'
    Template.groups.events
        'click .add_group': ->
            new_group = Docs.insert
                model:'group'
                leader_id: Meteor.userId()
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/group/#{new_group}/edit"
    Template.groups.helpers
        groups: ->
            Docs.find {
                model:'group'
            }, sort: _timestamp: -1


    Template.my_groups.onRendered ->
    Template.my_groups.onCreated ->
        @autorun => Meteor.subscribe 'my_groups'
    Template.my_groups.events
        'click .add_group': ->
            new_group = Docs.insert
                model:'group'
                leader_id: Meteor.userId()
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/group/#{new_group}/edit"
    Template.my_groups.helpers
        groups: ->
            Docs.find {
                model:'group'
            }, sort: _timestamp: -1

if Meteor.isServer
    Meteor.publish 'my_groups', ->
        Docs.find
            model:'group'
            leader_id:Meteor.userId()
