# Router.route '/tasks', -> @render 'tasks'
Router.route '/posts/', -> @render 'posts'
Router.route '/post/:doc_id/view', -> @render 'post_view'
Router.route '/post/:doc_id/edit', -> @render 'post_edit'

if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

if Meteor.isClient
    Template.posts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'post_stats'
        @autorun => Meteor.subscribe 'model_docs', 'post_update'
        @autorun => Meteor.subscribe 'model_comments', 'post'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'post'

    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.post_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.post_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'post_update', @data._id
    Template.post_card_template.helpers
        updates: ->
            Docs.find
                model:'post_update'
                parent_id: @_id


    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'post_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'ballot_posts', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_options', Router.current().params.doc_id
    Template.post_view.helpers
        options: ->
            Docs.find
                model:'post_option'
        posts: ->
            Docs.find
                model:'post'
                ballot_id: Router.current().params.doc_id
    Template.post_view.events
        'click .post_yes': ->
            my_post = Docs.findOne
                model:'post'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_post
                Docs.update my_post._id,
                    $set:value:'yes'
            else
                Docs.insert
                    model:'post'
                    ballot_id: Router.current().params.doc_id
                    value:'yes'
        'click .post_no': ->
            my_post = Docs.findOne
                model:'post'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_post
                Docs.update my_post._id,
                    $set:value:'no'
            else
                Docs.insert
                    model:'post'
                    ballot_id: Router.current().params.doc_id
                    value:'no'

    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_options', Router.current().params.doc_id
    Template.post_edit.events
        'click .add_option': ->
            Docs.insert
                model:'post_option'
                ballot_id: Router.current().params.doc_id
    Template.post_edit.helpers
        options: ->
            Docs.find
                model:'post_option'


    Template.posts.helpers
        posts: ->
            Docs.find
                model:'post'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'post'
            },
                limit:5
                sort:_timestamp:-1
        post_stats_doc: ->
            Docs.findOne
                model:'post_stats'

    Template.posts.events
        'click .add_post': ->
            new_id = Docs.insert
                model:'post'
            Router.go "/post/#{new_id}/edit"

        'click .recalc_posts': ->
            Meteor.call 'recalc_posts', ->

    # Template.latest_post_updates.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'post_update'
    #
    # Template.latest_post_updates.helpers
    #     latest_updates: ->
    #         Docs.find {
    #             model:'post_update'
    #         },
    #             limit:5
    #             sort:_timestamp:-1
    #
    #


    Template.posts_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'post'
    Template.posts_small.helpers
        posts: ->
            Docs.find {
                model:'post'
            },
                sort: _timestamp: -1
                limit:5



if Meteor.isServer
    Meteor.publish 'ballot_posts', (ballot_id)->
        Docs.find
            model:'post'
            ballot_id:ballot_id
    Meteor.publish 'post_options', (ballot_id)->
        Docs.find
            model:'post_option'
            ballot_id:ballot_id
    # Meteor.methods
        # recalc_posts: ->
        #     post_stat_doc = Docs.findOne(model:'post_stats')
        #     unless post_stat_doc
        #         new_id = Docs.insert
        #             model:'post_stats'
        #         post_stat_doc = Docs.findOne(model:'post_stats')
        #     console.log post_stat_doc
        #     total_count = Docs.find(model:'post').count()
        #     complete_count = Docs.find(model:'post', complete:true).count()
        #     incomplete_count = Docs.find(model:'post', complete:$ne:true).count()
        #     total_updates_count = Docs.find(model:'post_update').count()
        #     Docs.update post_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
        #             total_updates_count:total_updates_count
