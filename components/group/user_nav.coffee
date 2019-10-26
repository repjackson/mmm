if Meteor.isClient
    Template.user_footer.events
        'click .shortcut_modal': ->
            $('.ui.shortcut.modal').modal('show')
    Template.user_nav.onRendered ->
        # @autorun => Meteor.subscribe 'my_groups'

        # Meteor.setTimeout ->
        #     $('.dropdown').dropdown(
        #         on:'click'
        #     )
        # , 1000

        Meteor.setTimeout ->
            $('.item').popup(
                preserve:true;
                hoverable:false;
            )
        , 1000



    Template.user_nav.events
        # 'mouseenter .item': (e,t)->
            # $(e.currentTarget).closest('.item').transition('pulse', 400)
        'click .menu_dropdown': ->
            $('.menu_dropdown').dropdown(
                on:'hover'
            )


        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'


        'click .set_reference': ->
            Session.set 'loading', true
            # Meteor.call 'increment_view', @_id, ->
            Meteor.call 'set_facets', 'reference', ->
                Session.set 'loading', false

        'click .spinning': ->
            Session.set 'loading', false

    Template.user_footer_chat.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'footer_chat'
    Template.user_footer_chat.helpers
        chat_messages: ->
            Docs.find
                model:'footer_chat'
    Template.user_footer_chat.events
        'keyup .new_footer_chat_message': (e,t)->
            if e.which is 13
                new_message = $('.new_footer_chat_message').val()
                Docs.insert
                    model:'footer_chat'
                    text:new_message
                $('.new_footer_chat_message').val('')

        'click .remove_message': (e,t)->
            # if confirm 'remove message?'
            $(e.currentTarget).closest('.item').transition('fade right')
            Meteor.setTimeout =>
                Docs.remove @_id
            , 750

    Template.mlayout.onCreated ->
        @autorun -> Meteor.subscribe 'me'
    Template.user_nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'role_models'
        # @autorun -> Meteor.subscribe 'users_by_role','staff'
        @autorun => Meteor.subscribe 'global_settings'

        # @autorun -> Meteor.subscribe 'current_session'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.user_nav.helpers
        notifications: ->
            Docs.find
                model:'notification'
                model:'model'

        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()

        mail_icon_class: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()
            if unread_count then 'red' else ''

        my_groups: ->
            Docs.find {
                model:'group'
            }, sort: _timestamp: -1

        bookmarked_models: ->
            if Meteor.userId()
                Docs.find
                    model:'model'
                    bookmark_ids:$in:[Meteor.userId()]


    Template.my_latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'my_latest_activity'
    Template.my_latest_activity.helpers
        my_latest_activity: ->
            Docs.find {
                model:'log_event'
                _author_id:Meteor.userId()
            },
                sort:_timestamp:-1
                limit:5


    Template.latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'latest_activity'
    Template.latest_activity.helpers
        latest_activity: ->
            Docs.find {
                model:'log_event'
            },
                sort:_timestamp:-1
                limit:5
