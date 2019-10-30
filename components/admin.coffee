if Meteor.isClient
    Router.route '/admin/', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'

    Template.admin.onCreated ->
        @autorun -> Meteor.subscribe('task_facet_docs',
            selected_task_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )
        @autorun => Meteor.subscribe 'model_docs', 'admin_post'
        @autorun => Meteor.subscribe 'admins'

    Template.admin.helpers
        is_editing: ->
            Session.equals 'editing', @_id
        admins: ->
            Meteor.users.find {
                admin:true
            }
        tasks: ->
            Docs.find {
                model:'task'
            }, _timestamp:1
        admin_posts: ->
            Docs.find {
                model:'admin_post'
            }, _timestamp:1
    Template.admin.events
        'click .add_task': ->
            new_task_id =
                Docs.insert
                    model:'task'
            Session.set 'editing', new_task_id

        'click .edit': ->
            Session.set 'editing', @_id
        'click .save': ->
            Session.set 'editing', null


if Meteor.isServer
    Meteor.publish 'admins', ->
        Meteor.users.find
            admin:true
