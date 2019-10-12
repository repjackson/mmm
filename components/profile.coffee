if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile_view'
        ), name:'profile_view'


    Template.profile_view.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

    Template.profile_view.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.profile_view.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username

        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.profile_view.events
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
