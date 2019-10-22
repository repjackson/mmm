if Meteor.isClient
    Router.route '/teacher_dashboard', (->
        @layout 'teacher_layout'
        @render 'teacher_dashboard'
        ), name:'teacher_dashboard'

    Template.teacher_dashboard.onCreated ->
        Session.set 'username', null

    Template.teacher_dashboard.events
        'click .build_classroom': (e,t)->
            new_classroom_id = Docs.insert
                model:'classroom'
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/build_classroom/#{new_classroom_id}/info"


    Template.teacher_dashboard.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
