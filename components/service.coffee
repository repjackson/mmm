Router.route '/services', (->
    @render 'services'
    ), name:'services'
Router.route '/service/:doc_id/view', (->
    @render 'service_view'
    ), name:'service_view'
Router.route '/service/:doc_id/edit', (->
    @render 'service_edit'
    ), name:'service_edit'
Router.route '/kiosk_service_view/:doc_id', (->
    @layout 'mlayout'
    @render 'kiosk_service_view'
    ), name:'kiosk_service_view'


if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.kiosk_service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.service_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_history.helpers
        service_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.service_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to servicerk order."


    Template.service_time.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_time.events
        'click .mark_complete': ->
            if confirm 'mark complete?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        complete:true
                        complete_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'complete'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} marked servicerk order complete."


    Template.services.onCreated ->
        @autorun -> Meteor.subscribe 'service_docs', selected_service_tags.array()
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
    Template.services.helpers
        services: ->
            Docs.find {
                model:'service'
            },
                sort: _timestamp: -1
                # limit:7
    Template.service_small.onCreated ->
        @autorun -> Meteor.subscribe 'service_docs', selected_service_tags.array()
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
    Template.service_small.helpers
        services: ->
            Docs.find {
                model:'service'
            },
                sort: _timestamp: -1
                limit:5
    Template.service_small.events
        'click .log_service_view': ->
            console.log 'hi'
            # Docs.update @_id,
            #     $inc: views: 1


if Meteor.isServer
    Meteor.methods
        calc_service_stats: ->
            service_stat_doc = Docs.findOne(model:'service_stats')
            unless service_stat_doc
                new_id = Docs.insert
                    model:'service_stats'
                service_stat_doc = Docs.findOne(model:'service_stats')
            console.log service_stat_doc
            total_count = Docs.find(model:'service').count()
            complete_count = Docs.find(model:'service', complete:true).count()
            incomplete_count = Docs.find(model:'service', complete:$ne:true).count()
            Docs.update service_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
