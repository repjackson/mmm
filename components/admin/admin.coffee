if Meteor.isClient
    Router.route '/admin/', (->
        @layout 'admin_layout'
        @render 'admin'
        ), name:'admin'
    Router.route '/dev_blog/', (->
        @layout 'admin_layout'
        @render 'dev_blog'
        ), name:'dev_blog'

    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'admin_post'
        @autorun => Meteor.subscribe 'admins'

    Template.admin.helpers
        admins: ->
            Meteor.users.find {
                admin:true
            }
        admin_posts: ->
            Docs.find {
                model:'admin_post'
            }, _timestamp:1

if Meteor.isServer
    Meteor.publish 'admins', ->
        Meteor.users.find
            admin:true
