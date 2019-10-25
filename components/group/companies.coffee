if Meteor.isClient
    Template.companys.onRendered ->
        # Session.setDefault 'view_mode', 'cards'
    Template.companys.helpers
        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.companys.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.companys.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'company'
    Template.companys.events
        'click .add_company': ->
            new_company = Docs.insert
                model:'company'
            Router.go "/company/#{new_company}/edit"


    Template.companys.helpers
        companys: ->
            Docs.find {
                model:'company'
            }, sort: _timestamp: -1
