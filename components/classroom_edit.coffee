if Meteor.isClient
    Router.route '/classroom/:doc_id/edit', (->
        @layout 'layout'
        @render 'classroom_edit'
        ), name:'classroom_edit'


    Template.classroom_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.classroom_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
