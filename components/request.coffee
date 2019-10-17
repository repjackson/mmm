Router.route '/requests', (->
    @render 'requests'
    ), name:'requests'
Router.route '/request/:doc_id/view', (->
    @render 'request_view'
    ), name:'request_view'
Router.route '/request/:doc_id/edit', (->
    @render 'request_edit'
    ), name:'request_edit'


if Meteor.isClient
    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.grab_button.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.grab_button.events
        'click .grab': ->
            # if confirm 'grab this?'
            Meteor.call 'grab', @
        'click .get_on_deck': ->
            # if confirm 'get on deck?'
            Meteor.call 'get_on_deck', @

        'click .release': ->
            # if confirm 'release this?'
            Meteor.call 'release', @

    Template.request_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.request_history.helpers
        request_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id




    Template.request_time.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.request_time.events
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
                text: "#{Meteor.user().username} marked request order complete."


    Template.request_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'request'
    Template.request_small.helpers
        requests: ->
            Docs.find {
                model:'request'
            },
                sort: _timestamp: -1
                # limit:7
    Template.request_small.events
        'click .log_request_view': ->
            console.log 'hi'
            # Docs.update @_id,
            #     $inc: views: 1






if Meteor.isServer
    Meteor.methods
        grab: (request)->
            Docs.update request._id,
                $set:
                    grabber_id:Meteor.userId()
                    grab_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type: 'grab'
                text: "#{Meteor.user().name()} grabbed this."
                parent_id: request._id

        release: (request)->
            Docs.update request._id,
                $set:
                    grabber_id:null
                    release_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type: 'release'
                text: "#{Meteor.user().name()} released this."
                parent_id: request._id

        get_on_deck: (request)->
            position = if request.waitlist then request.waitlist.length else 0
            Docs.update request._id,
                $set:
                    on_deck_id: Meteor.userId()
                    # waitlist: {
                    #     user_id: Meteor.userId()
                    #     add_timestamp: Date.now()
                    #     position: position
                    # }

            Docs.insert
                model:'log_event'
                log_type: 'join_waitlist'
                text: "#{Meteor.user().name()} joined waitlist at ."
                parent_id: request._id




        calc_request_stats: ->
            request_stat_doc = Docs.findOne(model:'request_stats')
            unless request_stat_doc
                new_id = Docs.insert
                    model:'request_stats'
                request_stat_doc = Docs.findOne(model:'request_stats')
            console.log request_stat_doc
            total_count = Docs.find(model:'request').count()
            complete_count = Docs.find(model:'request', complete:true).count()
            incomplete_count = Docs.find(model:'request', complete:$ne:true).count()
            Docs.update request_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
