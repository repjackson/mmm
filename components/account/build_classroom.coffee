if Meteor.isClient
    Router.route '/build_classroom/:doc_id', (->
        @layout 'mlayout'
        @render 'build_classroom_finance'
        ), name:'build_classroom_home'
    Router.route '/build_classroom/:doc_id/finance', (->
        @layout 'mlayout'
        @render 'build_classroom_finance'
        ), name:'build_classroom_finance'
    Router.route '/build_classroom/:doc_id/info', (->
        @layout 'mlayout'
        @render 'build_classroom_info'
        ), name:'build_classroom_info'
    Router.route '/build_classroom/:doc_id/students', (->
        @layout 'mlayout'
        @render 'build_classroom_students'
        ), name:'build_classroom_students'

    Template.build_classroom_info.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.build_classroom_info.events
    Template.build_classroom_info.helpers

    Template.build_classroom_finance.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.build_classroom_finance.events
    Template.build_classroom_finance.helpers

    Template.build_classroom_students.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students_by_classroom_id', Router.current().params.doc_id
    Template.build_classroom_students.events
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_student', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        alert err
                    else
                        $('#first_name').val('')
                        $('#last_name').val('')
        'click .remove_student': ->
            if confirm "remove #{first_name} #{last_name}?"
                Meteor.users.remove @_id


    Template.build_classroom_students.helpers
        classroom_students: ->
            Meteor.users.find
                roles:$in:['student']
                classroom_id:Router.current().params.doc_id




if Meteor.isServer
    Meteor.publish 'classroom_students_by_classroom_id', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            roles:$in:['student']
            classroom_id:classroom_id

    Meteor.methods
        add_student: (first_name, last_name, classroom_id)->
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"

            options = {}
            options.username = username

            res= Accounts.createUser options
            if res
                Meteor.users.update res,
                    $set:
                        first_name: first_name
                        last_name: last_name
                        classroom_id: classroom_id
                        added_by_username: Meteor.user().username
                        added_by_user_id: Meteor.userId()
                        roles: ['student']
                return res
            else
                Throw.new Meteor.Error 'err creating user'
