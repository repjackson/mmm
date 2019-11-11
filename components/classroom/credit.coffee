if Meteor.isClient
    Template.classroom_edit_credits.helpers
        classroom_credit_types: ->
            if Session.get 'editing_credit_id'
                Docs.find Session.get('editing_credit_id')
            else
                Docs.find
                    model:'credit_type'
                    classroom_id: Router.current().params.doc_id
                    # template_id:$exists:true
        # custom_credit_types: ->
        #     Docs.find
        #         model:'credit_type'
        #         classroom_id: Router.current().params.doc_id
        #         template_id:$exists:false
        # selected_credit: ->
        #     Docs.findOne Session.get('selected_credit_id')
    Template.classroom_edit_credits.events
        'click .select_credit': -> Session.set 'selected_credit_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
            # Session.set 'selected_credit_id', new_credit_id
            Session.set 'editing_credit_id', new_credit_id
        'click .remove_credit': ->
            Docs.remove @_id



    Template.credit.onCreated ->
        # @editing_credit = new ReactiveVar false
        # Session.set 'editing_credit_id', null
    Template.credit.helpers
        # is_editing: ->
        #     Session.get 'editing_credit_id'
        editing_credit: ->
            Session.equals('editing_credit_id', @_id)
            # Template.instance().editing_credit.get()
    Template.credit.events
        'click .remove_credit': (e,t)->
            if confirm "remove #{@title}?"
                $(e.currentTarget).closest('.segment').transition('fade right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
                Session.set 'editing_credit_id', null

        'click .save_credit': (e,t)->
            Session.set 'editing_credit_id', null
            # console.log 'hi'
            # t.editing_credit.set false
        'click .edit_credit': (e,t)->
            Session.set 'editing_credit_id', @_id
            # console.log 'hi'
            # t.editing_transaction.set true
