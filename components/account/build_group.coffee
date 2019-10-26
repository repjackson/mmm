if Meteor.isClient
    Router.route '/build_group', (->
        @layout 'mlayout'
        @render 'build_group'
        ), name:'build_group'

    Template.build_group.onCreated ->
        Session.set 'username', null

    Template.build_group.events
        'click .build_group': (e,t)->
            new_group_id = Docs.insert
                model:'group'
                leader_id: Meteor.userId()
                salary_amount:100
                bonus_amount:1
                overtime_amount:3
                desk_rental_amount:50
                fines_amount:1
                janitor_base_amount:3
                janitor_extra_amount:2
                lunch_base_amount:3
                lunch_extra_amount:2
            Router.go "/build_group/#{new_group_id}/info"


    Template.build_group.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
