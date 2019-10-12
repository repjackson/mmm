if Meteor.isClient
    Router.route '/admin', -> @render 'admin'
    Router.route '/student_dash', -> @render 'student_dash'
    Router.route '/teachers', -> @render 'teacher_dash'
    Router.route '/classrooms', -> @render 'classrooms'

    Template.add_student.onCreated ->
        Session.set 'permission', false

    Template.add_student.events
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            # $('#username').val("#{first_name.toLowerCase()}_#{last_name.toLowerCase()}")
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Session.set 'permission',true
            if e.which is 13
                Meteor.call 'add_user', username, (err,res)=>
                    if err
                        alert err
                    else
                        Meteor.users.update res,
                            $set:
                                first_name:first_name
                                last_name:last_name
                                added_by_username:Meteor.user().username
                                added_by_user_id:Meteor.userId()
                                roles:['student']
                                # healthclub_checkedin:true
                        Docs.insert
                            model: 'log_event'
                            object_id: res
                            body: "#{username} was created"
                        # Docs.insert
                        #     model:'log_event'
                        #     object_id:res
                        #     body: "#{username} checked in."
                        new_user = Meteor.users.findOne res
                        Session.set 'username_query',null
                        $('.username_search').val('')
                        Meteor.call 'email_verified',new_user
                        Router.go "/user/#{username}/edit"


        'click .create_student': ->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Meteor.call 'add_user', username, (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                            added_by_username:Meteor.user().username
                            added_by_user_id:Meteor.userId()
                            roles:['student']
                            # healthclub_checkedin:true
                    Docs.insert
                        model: 'log_event'
                        object_id: res
                        body: "#{username} was created"
                    # Docs.insert
                    #     model:'log_event'
                    #     object_id:res
                    #     body: "#{username} checked in."
                    new_user = Meteor.users.findOne res
                    Session.set 'username_query',null
                    $('.username_search').val('')
                    Meteor.call 'email_verified',new_user
                    Router.go "/user/#{username}/edit"


    Template.add_student.helpers
        permission: -> Session.get 'permission'




    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'model_docs', 'payment'
        @autorun => Meteor.subscribe 'model_docs', 'payment'
    Template.admin.helpers
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
            }, sort: _timestamp: -1

        payments: ->
            Docs.find {
                model:'payment'
            }, sort: _timestamp: -1

    Template.call_method.events
        'click .call_method': ->
            Meteor.call @name



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id




if Meteor.isServer
    Meteor.methods
        calculate_model_doc_count: ->
            model_cursor = Docs.find(model:'model')
            console.log model_cursor.count()
            for model in model_cursor.fetch()
                model_docs_count =
                    Docs.find(
                        model:model.slug
                    ).count()
                console.log model.slug, model_docs_count
