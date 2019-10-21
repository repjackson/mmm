if Meteor.isClient
    Router.route '/build_classroom/:doc_id', (->
        @layout 'no_footer_layout'
        @render 'build_classroom'
        ), name:'build_classroom'

    Template.build_classroom.onCreated ->
        Session.set 'username', null
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.build_classroom.events


    Template.build_classroom.helpers
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
