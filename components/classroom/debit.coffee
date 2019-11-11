if Meteor.isClient
    Template.classroom_edit_debits.events
        # 'click .select_debit': -> Session.set 'selected_debit_id', @_id
        'click .add_debit_type': ->
            new_debit_id = Docs.insert
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
            # Session.set 'selected_debit_id', new_debit_id
            Session.set 'editing_debit_id', new_debit_id
    Template.classroom_edit_debits.helpers
        # selected_debit: ->
        #     Docs.findOne Session.get('selected_debit_id')
        # template_debit_types: ->
        #     Docs.find
        #         model:'debit_type'
        #         classroom_id: Router.current().params.doc_id
        #         # template_id:$exists:true
        classroom_debit_types: ->
            if Session.get 'editing_debit_id'
                Docs.find Session.get('editing_debit_id')
            else
                Docs.find
                    model:'debit_type'
                    classroom_id: Router.current().params.doc_id
                    # template_id:$exists:false


    Template.debit.onCreated ->
        # @editing_debit = new ReactiveVar false
        # Session.set 'editing_id', null
    Template.debit.helpers
        # is_editing: ->
        #     Session.get 'editing_id'
        editing_debit: ->
            Session.equals('editing_debit_id', @_id)
            # Template.instance().editing_debit.get()
    Template.debit.events
        'click .remove_debit': (e,t)->
            if confirm "remove #{@title}?"
                $(e.currentTarget).closest('.segment').transition('fade right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
                Session.set 'editing_debit_id', null


        'click .save_debit': (e,t)->
            Session.set 'editing_debit_id', null
            # console.log 'hi'
            # t.editing_debit.set false
        'click .edit_debit': (e,t)->
            Session.set 'editing_debit_id', @_id
            # console.log 'hi'
            # t.editing_transaction.set true
