if Meteor.isClient
    Router.route '/build_world', (->
        @layout 'no_footer_layout'
        @render 'build_world'
        ), name:'build_world'

    Template.build_world.onCreated ->
        Session.set 'username', null

    Template.build_world.events
        'click .build_classroom': (e,t)->
            new_classroom_id = Docs.insert
                model:'classroom'
                teacher_id: Meteor.userId()
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


    Template.build_world.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
