if Meteor.isClient
    Router.route '/p/:slug', -> @render 'page'

    Template.page.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'page_doc', Router.current().params.slug
    Template.page.helpers
        page_doc: ->
            Docs.findOne
                model:'page'
                slug:Router.current().params.slug


if Meteor.isServer
    Meteor.publish 'page_doc', (page_slug)->
        Docs.find
            model:'page'
            slug:page_slug
