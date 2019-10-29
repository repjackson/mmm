if Meteor.isClient
    Router.route '/admin/', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'

    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task'

    Template.admin.helpers
        tasks: ->
            Docs.find {
                model:'task'
            }, _timestamp:1
    Template.admin.events
        'click .add_task': ->
            new_task_id =
                Docs.insert
                    model:'task'
            Router.go "/task/#{new_task_id}/edit"
