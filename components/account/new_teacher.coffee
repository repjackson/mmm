if Meteor.isClient
    Router.route '/new_teacher', (->
        @layout 'no_footer_layout'
        @render 'new_teacher'
        ), name:'new_teacher'

    Template.new_teacher.onCreated ->
        Session.set 'username', null

    Template.new_teacher.events
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
                Meteor.users.update res,
                    $set: roles: ['teacher']
                Meteor.loginWithPassword username, password, (err,res)=>
                    if err
                        alert err.reason
                        # if err.error is 403
                        #     Session.set 'message', "#{username} not found"
                        #     Session.set 'enter_mode', 'register'
                        #     Session.set 'username', "#{username}"
                    else
                        Router.go "/build_world"
                        # Router.go "/teacher/#{username}/edit"
            # else
            #     Meteor.loginWithPassword username, password, (err,res)=>
            #         if err
            #             if err.error is 403
            #                 Session.set 'message', "#{username} not found"
            #                 Session.set 'enter_mode', 'register'
            #                 Session.set 'username', "#{username}"
            #         else
            #             Router.go '/'


    Template.new_teacher.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
