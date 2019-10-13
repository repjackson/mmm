if Meteor.isClient
    Router.route '/slides', (->
        @layout 'layout'
        @render 'slides'
        ), name:'slides'
    Router.route '/slide/:doc_id/edit', (->
        @layout 'layout'
        @render 'slide_edit'
        ), name:'slide_edit'
    Router.route '/slide/:doc_id/view', (->
        @layout 'layout'
        @render 'slide_view'
        ), name:'slide_view'



    Template.slide_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.slide_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.slide_edit.events
        'click .add_slide_item': ->
            new_mi_id = Docs.insert
                model:'slide_item'
            Router.go "/slide/#{_id}/edit"


    Template.slide_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.slide_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.slides.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'slide'
    Template.slides.helpers
        slides: ->
            Docs.find
                model:'slide'
    Template.slides.events
        'click .add_slide': ->
            new_slide_id = Docs.insert
                model:'slide'
            Router.go "/slide/#{new_slide_id}/edit"



if Meteor.isServer
    Meteor.publish 'slides', (product_id)->
        Docs.find
            model:'slide'
            product_id:product_id
