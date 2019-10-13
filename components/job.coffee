if Meteor.isClient
    Router.route '/jobs', (->
        @layout 'layout'
        @render 'jobs'
        ), name:'jobs'
    Router.route '/job/:doc_id/edit', (->
        @layout 'layout'
        @render 'job_edit'
        ), name:'job_edit'
    Router.route '/job/:doc_id/view', (->
        @layout 'layout'
        @render 'job_view'
        ), name:'job_view'



    Template.job_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.job_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.job_edit.events
        'click .add_job_item': ->
            new_mi_id = Docs.insert
                model:'job_item'
            Router.go "/job/#{_id}/edit"


    Template.job_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.job_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->

    Template.jobs.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'job'
    Template.jobs.helpers
        jobs: ->
            Docs.find
                model:'job'

    Template.jobs_view_template.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'job'
    Template.jobs_view_template.helpers
        jobs: ->
            Docs.find
                model:'job'
    Template.jobs_view_template.events
        'click .take_job': ->
            console.log @




    Template.jobs.events
        'click .add_job': ->
            new_job_id = Docs.insert
                model:'job'
            Router.go "/job/#{new_job_id}/edit"



    Template.job_stats.events
        'click .refresh_job_stats': ->
            Meteor.call 'refresh_job_stats', @_id




if Meteor.isServer
    Meteor.publish 'jobs', (product_id)->
        Docs.find
            model:'job'
            product_id:product_id

    Meteor.methods
        refresh_job_stats: (job_id)->
            job = Docs.findOne job_id
            # console.log job
            reservations = Docs.find({model:'reservation', job_id:job_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_job_hours = 0
            average_job_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_job_hours += parseFloat(res.hour_duration)

            average_job_cost = total_earnings/reservation_count
            average_job_duration = total_job_hours/reservation_count

            Docs.update job_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_job_hours: total_job_hours.toFixed(0)
                    average_job_cost: average_job_cost.toFixed(0)
                    average_job_duration: average_job_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header job ranking #reservations
            # .ui.small.header job ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg job time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
