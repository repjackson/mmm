if Meteor.isClient
    Router.route '/register', (->
        @layout 'layout'
        @render 'register'
        ), name:'register'
    Router.route '/onboarding', (->
        @layout 'mlayout'
        @render 'onboarding'
        ), name:'onboarding'
    Router.route '/choose_personas', (->
        @layout 'mlayout'
        @render 'choose_personas'
        ), name:'choose_personas'
    Router.route '/choose_interests', (->
        @layout 'mlayout'
        @render 'choose_interests'
        ), name:'choose_interests'

    Template.choose_personas.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'user_persona'
    Template.choose_personas.events
        'click .select_persona': ->
            if Meteor.user().personas
                if @slug in Meteor.user().personas
                    Meteor.users.update Meteor.userId(),
                         $pull: personas: @slug
                 else
                     Meteor.users.update Meteor.userId(),
                         $addToSet: personas: @slug
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: personas: @slug
    Template.choose_personas.helpers
        persona_class: ->
            if Meteor.user().personas and @slug in Meteor.user().personas then 'active' else ''
        user_personas: ->
            Docs.find
                model:'user_persona'




    Template.choose_interests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'user_interest'
    Template.choose_interests.events
        'click .select_interest': ->
            if Meteor.user().interests
                if @slug in Meteor.user().interests
                    Meteor.users.update Meteor.userId(),
                         $pull: interests: @slug
                 else
                     Meteor.users.update Meteor.userId(),
                         $addToSet: interests: @slug
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: interests: @slug
    Template.choose_interests.helpers
        interest_class: ->
            if Meteor.user().interests and @slug in Meteor.user().interests then 'active' else ''
        user_interests: ->
            Docs.find
                model:'user_interest'









    Template.register.onCreated ->
        Session.set 'username', null
    Template.register.events
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'


        'click .enter': (e,t)->
            username = $('.username').val()
            password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            options = {
                username:username
                password:password
                }
            Meteor.call 'create_user', options, (err,res)->
                Meteor.loginWithPassword username, password, (err,res)=>
                    if err
                        alert err.reason
                        # if err.error is 403
                        #     Session.set 'message', "#{username} not found"
                        #     Session.set 'enter_mode', 'register'
                        #     Session.set 'username', "#{username}"
                    else
                        Router.go "/onboarding"
            # else
            #     Meteor.loginWithPassword username, password, (err,res)=>
            #         if err
            #             if err.error is 403
            #                 Session.set 'message', "#{username} not found"
            #                 Session.set 'enter_mode', 'register'
            #                 Session.set 'username', "#{username}"
            #         else
            #             Router.go '/'


    Template.register.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''


if Meteor.isServer
    Meteor.methods
        create_user: (options)->
            Accounts.createUser options

        can_submit: ->
            username = Session.get 'username'
            email = Session.get 'email'
            password = Session.get 'password'
            password2 = Session.get 'password2'
            if username and email
                if password.length > 0 and password is password2
                    true
                else
                    false


        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                # console.log res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Meteor.users.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Meteor.users.findOne create
            return new_user
