if Meteor.isClient
    Router.route '/tasks/', (->
        @layout 'admin_layout'
        @render 'tasks'
        ), name:'tasks'

    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe('task_facet_docs',
            selected_task_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )

    Template.tasks.helpers
        tasks: ->
            Docs.find {
                model:'task'
            }, _timestamp:1


    Template.tasks.events
        'click .add_task': ->
            new_task_id =
                Docs.insert
                    model:'task'
            Session.set 'editing', new_task_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null
