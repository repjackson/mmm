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
    Router.route '/classroom/:doc_id/edit/templates', (->
        @layout 'classroom_edit_layout'
        @render 'classroom_edit_templates'
        ), name:'classroom_edit_templates'


    Template.classroom_edit_layout.onRendered ->
    Template.classroom_edit_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'

    Template.classroom_edit_debits.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'classroom_docs', 'debit_type', Router.current().params.doc_id

    Template.classroom_edit_credits.onCreated ->
        @autorun => Meteor.subscribe 'classroom_docs', 'credit_type', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        # Session.set 'permission', false

    Template.classroom_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 750


    Template.classroom_edit_credits.helpers
        credit_types: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id




    Template.classroom_edit_debits.events
        'click .select_debit': -> Session.set 'selected_debit_id', @_id
        'click .add_debit_type': ->
            new_debit_id = Docs.insert
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
            Session.set 'selected_debit_id', new_debit_id
    Template.classroom_edit_debits.helpers
        debit_class: ->
            if Session.equals('selected_debit_id',@_id) then 'active' else ''
        selected_debit: ->
            Docs.findOne Session.get('selected_debit_id')
        debit_types: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id



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
        'click .remove_credit': ->
            Docs.remove @_id




    Template.transaction.onCreated ->
        @editing_transaction = new ReactiveVar false
    Template.transaction.helpers
        editing_transaction: -> Template.instance().editing_transaction.get()
    Template.transaction.events
        'click .save_transaction': (e,t)->
            t.editing_transaction.set false
        'click .edit_transaction': (e,t)->
            t.editing_transaction.set true




    Template.classroom_edit_templates.onRendered ->
    Template.classroom_edit_templates.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'transaction_template'
    Template.classroom_edit_templates.helpers
        transaction_templates: ->
            Docs.find
                model:'transaction_template'
        my_transaction_templates: ->
            Docs.find
                model:'transaction_template'
                _author_id: Meteor.userId()
        selected_template: ->
            Docs.findOne Session.get('selected_template_id')
        template_class: ->
            if Session.equals('selected_template_id',@_id) then 'active' else ''

    Template.classroom_edit_templates.events
        'click .generate_from_current': ->
            group = Docs.findOne Router.current().params.doc_id
            new_template_id = Docs.insert
                model:'transaction_template'
                title:group.company_name
                classroom_company_name: group.company_name
                classroom_id: Router.current().params.doc_id
            Session.set 'selected_template_id', new_template_id
        'click .select_template': -> Session.set 'selected_template_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                classroom_id: Router.current().params.doc_id






    Template.template.onCreated ->
        @editing_template = new ReactiveVar false
        console.log @data
        @autorun => Meteor.subscribe 'classroom_docs', 'credit_type', @data.classroom_id
        @autorun => Meteor.subscribe 'classroom_docs', 'debit_type', @data.classroom_id

    Template.template.helpers
        editing_template: -> Template.instance().editing_template.get()
        classroom_debits: ->
            Docs.find
                model:'debit_type'
        classroom_credits: ->
            Docs.find
                model:'credit_type'
    Template.template.events
        'click .clone_template': ->
            # console.log @
            group_credits =
                Docs.find(
                    model:'credit_type'
                    classroom_id: @classroom_id
                ).fetch()
            for credit in group_credits
                # console.log 'cloning credit', credit
                new_credit_object = {}
                new_credit_object.model = 'credit_type'
                new_credit_object.classroom_id = Router.current().params.doc_id

                if credit.title
                    new_credit_object.title = credit.title
                if credit.amount
                    new_credit_object.amount = credit.amount
                if credit.description
                    new_credit_object.description = credit.description
                if credit.dispersion_type
                    new_credit_object.dispersion_type = credit.dispersion_type
                if credit.icon
                    new_credit_object.icon = credit.icon
                if credit.manual_limit_type
                    new_credit_object.manual_limit_type = credit.manual_limit_type
                if credit.manual_period
                    new_credit_object.manual_period = credit.manual_period
                if credit.scope
                    new_credit_object.scope = credit.scope
                Docs.insert new_credit_object
                $('body').toast({
                    message: "credit #{credit.title} was cloned"
                    class:'success'
                    showProgress: 'bottom'
                })

            group_debits =
                Docs.find(
                    model:'debit_type'
                    classroom_id: @classroom_id
                ).fetch()
            console.log group_debits
        'click .save_template': (e,t)->
            t.editing_template.set false
        'click .edit_template': (e,t)->
            t.editing_template.set true
