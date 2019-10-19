if Meteor.isClient
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'
    Router.route '/task/:doc_id/view', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'



    Template.task_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.task_edit.events
        'click .add_task_item': ->
            new_mi_id = Docs.insert
                model:'task_item'
            Router.go "/task/#{_id}/edit"


    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.task_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->

    Template.tasks.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'task'
    Template.tasks.helpers
        tasks: ->
            Docs.find
                model:'task'

    Template.tasks_view_template.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'task'
    Template.tasks_view_template.helpers
        tasks: ->
            Docs.find
                model:'task'
    Template.tasks_view_template.events
        'click .take_task': ->
            console.log @




    Template.tasks.events
        'click .add_task': ->
            new_task_id = Docs.insert
                model:'task'
            Router.go "/task/#{new_task_id}/edit"



    Template.task_stats.events
        'click .refresh_task_stats': ->
            Meteor.call 'refresh_task_stats', @_id




if Meteor.isServer
    Meteor.publish 'tasks', (product_id)->
        Docs.find
            model:'task'
            product_id:product_id

    Meteor.methods
        refresh_task_stats: (task_id)->
            task = Docs.findOne task_id
            # console.log task
            reservations = Docs.find({model:'reservation', task_id:task_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_task_hours = 0
            average_task_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_task_hours += parseFloat(res.hour_duration)

            average_task_cost = total_earnings/reservation_count
            average_task_duration = total_task_hours/reservation_count

            Docs.update task_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_task_hours: total_task_hours.toFixed(0)
                    average_task_cost: average_task_cost.toFixed(0)
                    average_task_duration: average_task_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header task ranking #reservations
            # .ui.small.header task ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg task time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
