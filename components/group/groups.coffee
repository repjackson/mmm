if Meteor.isClient
    Template.groups.onRendered ->
    Template.groups.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'group'
        @autorun -> Meteor.subscribe('group_facet_docs',
            selected_group_tags.array()
            # Session.get('sort_key')
        )

    Template.groups.events
        'click .add_group': ->
            new_group = Docs.insert
                model:'group'
                leader_id: Meteor.userId()
            Router.go "/group/#{new_group}/edit"
    Template.groups.helpers
        groups: ->
            Docs.find {
                model:'group'
            }, sort: _timestamp: -1


    # Template.my_groups.onRendered ->
    # Template.my_groups.onCreated ->
    #     @autorun => Meteor.subscribe 'my_groups'
    #     @autorun => Meteor.subscribe 'model_docs', 'group'
    # Template.my_groups.events
    #     'click .add_group': ->
    #         new_group = Docs.insert
    #             model:'group'
    #             leader_id: Meteor.userId()
    #         Router.go "/group/#{new_group}/edit"
    # Template.my_groups.helpers
    #     groups: ->
    #         Docs.find {
    #             model:'group'
    #         }, sort: _timestamp: -1


    Template.group_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group_stats'
    Template.groups.helpers



if Meteor.isServer
    Meteor.publish 'my_groups', ->
        Docs.find
            model:'group'
            leader_id:Meteor.userId()
