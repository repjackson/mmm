if Meteor.isClient
    Router.route '/classroom/:doc_id/edit', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_students'
        ), name:'classroom_edit'
    Router.route '/classroom/:doc_id/edit/info', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_info'
        ), name:'classroom_edit_info'
    Router.route '/classroom/:doc_id/edit/students', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_students'
        ), name:'classroom_edit_students'
    Router.route '/classroom/:doc_id/edit/credits', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_credits'
        ), name:'classroom_edit_credits'
    Router.route '/classroom/:doc_id/edit/debits', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_debits'
        ), name:'classroom_edit_debits'


    Template.classroom_edit_layout.onRendered ->
    Template.classroom_edit_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'

    Template.classroom_edit_debits.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'

    Template.classroom_edit_credits.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        # @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        # Session.set 'permission', false

    Template.classroom_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 750

    Template.classroom_edit_layout.helpers
        # features: ->
        #     Docs.find
        #         model:'feature'

    Template.classroom_edit_credits.helpers
        credit_types: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id

    Template.classroom_edit_debits.events
        'click .select_debit': -> Session.set 'selected_debit_id', @_id
        'click .add_debit_type': ->
            Docs.insert
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
    Template.classroom_edit_debits.helpers
        debit_class: ->
            if Session.equals('selected_debit_id',@_id) then 'active' else ''
        selected_debit: ->
            Docs.findOne Session.get('selected_debit_id')
        debit_types: ->
            new_debit_id = Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
            Session.set 'selected_debit_id', new_debit_id

    Template.classroom_edit_layout.helpers

    Template.classroom_edit_credits.helpers
        credit_class: ->
            if Session.equals('selected_credit_id',@_id) then 'active' else ''
        selected_credit: ->
            Docs.findOne Session.get('selected_credit_id')

    Template.classroom_edit_credits.events
        'click .select_credit': -> Session.set 'selected_credit_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
            Session.set 'selected_credit_id', new_credit_id

    Template.classroom_edit_layout.events
        'click .set_adding_student': ->
            Session.set 'adding_student', true
