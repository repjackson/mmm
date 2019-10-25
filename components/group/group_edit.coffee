if Meteor.isClient
    Router.route '/group/:doc_id/edit', (->
        @layout 'group_edit_layout'
        @render 'group_edit_members'
        ), name:'group_edit'
    Router.route '/group/:doc_id/edit/info', (->
        @layout 'group_edit_layout'
        @render 'group_edit_info'
        ), name:'group_edit_info'
    Router.route '/group/:doc_id/edit/settings', (->
        @layout 'group_edit_layout'
        @render 'group_edit_settings'
        ), name:'group_edit_settings'
    Router.route '/group/:doc_id/edit/members', (->
        @layout 'group_edit_layout'
        @render 'group_edit_members'
        ), name:'group_edit_members'

    Router.route '/group/:doc_id/edit/f/:feature_slug', (->
        @layout 'group_edit_layout'
        @render 'group_edit_feature'
        ), name:'group_edit_feature'
    Router.route '/group/:doc_id/edit/debits', (->
        @layout 'group_edit_layout'
        @render 'group_edit_debits'
        ), name:'group_edit_debits'
    Router.route '/group/:doc_id/edit/templates', (->
        @layout 'group_edit_layout'
        @render 'group_edit_templates'
        ), name:'group_edit_templates'
    Router.route '/group/:doc_id/edit/features', (->
        @layout 'group_edit_layout'
        @render 'group_edit_features'
        ), name:'group_edit_features'


    # Template.group_edit_layout.onRendered ->
    Template.group_edit_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.group_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 750
    Template.group_edit_layout.helpers
        enabled_features: ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'feature'
                _id: $in: group.enabled_feature_ids






    Template.group_edit_debits.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'group_docs', 'debit_type', Router.current().params.doc_id

    Template.group_edit_credits.onCreated ->
        @autorun => Meteor.subscribe 'group_docs', 'credit_type', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        # Session.set 'permission', false


    Template.group_edit_settings.onCreated ->
        @autorun => Meteor.subscribe 'all_group_docs', Router.current().params.doc_id


    Template.group_edit_settings.events
        'click .remove_group': ->
            console.log @
            group_docs =
                Docs.find(
                    group_id: @_id
                )
            console.log group_docs
            if confirm "confirm delete group? this will delete #{group_docs.count()} group documents"
                for group_doc in group_docs.fetch()
                    Docs.remove group_doc._id
                    $('body').toast({
                        message: "#{group_doc.model} deleted"
                        class:'info'
                    })
                Docs.remove @_id
                Router.go '/my_groups'



    Template.group_edit_debits.events
        'click .select_debit': -> Session.set 'selected_debit_id', @_id
        'click .add_debit_type': ->
            new_debit_id = Docs.insert
                model:'debit_type'
                group_id: Router.current().params.doc_id
            Session.set 'selected_debit_id', new_debit_id
    Template.debit_menu_item.helpers
        debit_class: ->
            if Session.equals('selected_debit_id',@_id) then 'active' else ''
    Template.group_edit_debits.helpers
        selected_debit: ->
            Docs.findOne Session.get('selected_debit_id')
        template_debit_types: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                template_id:$exists:true
        custom_debit_types: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                template_id:$exists:false





    Template.credit_menu_item.helpers
        credit_class: ->
            if Session.equals('selected_credit_id',@_id) then 'active' else ''
    Template.group_edit_credits.helpers
        template_credit_types: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                template_id:$exists:true
        custom_credit_types: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                template_id:$exists:false
        selected_credit: ->
            Docs.findOne Session.get('selected_credit_id')
    Template.group_edit_credits.events
        'click .select_credit': -> Session.set 'selected_credit_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                group_id: Router.current().params.doc_id
            Session.set 'selected_credit_id', new_credit_id
        'click .remove_credit': ->
            Docs.remove @_id




    Template.transaction.onCreated ->
        @editing_transaction = new ReactiveVar false
    Template.transaction.helpers
        editing_transaction: -> Template.instance().editing_transaction.get()
    Template.transaction.events
        'click .remove_transaction': (e,t)->
            if confirm "remove #{@title}?"
                $(e.currentTarget).closest('.segment').transition('fade right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

        'click .save_transaction': (e,t)->
            t.editing_transaction.set false
        'click .edit_transaction': (e,t)->
            t.editing_transaction.set true




    Template.group_edit_templates.onRendered ->
    Template.group_edit_templates.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'transaction_template'
    Template.group_edit_templates.helpers
        transaction_templates: ->
            Docs.find
                model:'transaction_template'
        my_transaction_templates: ->
            Docs.find
                model:'transaction_template'
                _author_id: Meteor.userId()
        selected_template: -> Docs.findOne Session.get('selected_template_id')
        template_class: -> if Session.equals('selected_template_id',@_id) then 'active' else ''
    Template.group_edit_templates.events
        'click .generate_from_current': ->
            group = Docs.findOne Router.current().params.doc_id
            new_template_id = Docs.insert
                model:'transaction_template'
                title:group.company_name
                group_company_name: group.company_name
                group_id: Router.current().params.doc_id
            Session.set 'selected_template_id', new_template_id
        'click .select_template': -> Session.set 'selected_template_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                group_id: Router.current().params.doc_id



    Template.group_edit_features.onRendered ->
    Template.group_edit_features.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.group_edit_features.helpers
        group_monthly_bill: ->
            bill = 0
            group = Docs.findOne Router.current().params.doc_id
            enabled_features =
                Docs.find(
                    model:'feature'
                    _id: $in: group.enabled_feature_ids
                ).fetch()
            for feature in enabled_features
                bill += feature.monthly_price
            bill

        disabled_features: ->
            group = Docs.findOne Router.current().params.doc_id
            match = {model:'feature'}
            if group.enabled_feature_ids
                match._id = $nin: group.enabled_feature_ids
            Docs.find match
        enabled_features: ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'feature'
                _id: $in: group.enabled_feature_ids
        selected_feature: -> Docs.findOne Session.get('selected_feature_id')
        feature_class: -> if Session.equals('selected_feature_id',@_id) then 'active' else ''
    Template.group_edit_features.events
        'click .select_feature': -> Session.set 'selected_feature_id', @_id
        'click .add_feature': ->
            new_feature_id = Docs.insert
                model:'feature'
            Session.set 'selected_feature_id', new_feature_id


    Template.feature.onCreated ->
        @editing_feature = new ReactiveVar false
    Template.feature.helpers
        editing_feature: -> Template.instance().editing_feature.get()
        enabled: ->
            group = Docs.findOne Router.current().params.doc_id
            if @_id in group.enabled_feature_ids then true else false
        feature_class: ->
            group = Docs.findOne Router.current().params.doc_id
            if @_id in group.enabled_feature_ids then 'green raised' else ''
    Template.feature.events
        'click .enable_feature': ->
            if @dependencies and @dependencies.length
                if confirm "#{@title} is dependent on #{@dependencies}, each will be installed, confirm?"
                    Docs.update Router.current().params.doc_id,
                        $addToSet: enabled_feature_ids: @_id
                    $('body').toast({
                        message: "#{@title} enabled"
                        class:'success'
                        # showProgress: 'bottom'
                    })
                    for dependent in @dependencies
                        feature = Docs.findOne({model:'feature', slug:dependent})
                        Docs.update Router.current().params.doc_id,
                            $addToSet: enabled_feature_ids: feature._id
                        $('body').toast({
                            message: "#{dependent} enabled"
                            class:'success'
                        })

            else
                Docs.update Router.current().params.doc_id,
                    $addToSet: enabled_feature_ids: @_id
                $('body').toast({
                    message: "#{@title} enabled"
                    class:'success'
                    # showProgress: 'bottom'
                })


        'click .disable_feature': ->
            Docs.update Router.current().params.doc_id,
                $pull: enabled_feature_ids: @_id
            $('body').toast({
                message: "#{@title} disabled"
                class:'info'
                # showProgress: 'bottom'
            })
        'click .save_feature': (e,t)->
            t.editing_feature.set false
        'click .edit_feature': (e,t)->
            t.editing_feature.set true





    Template.group_edit_feature.onRendered ->
    Template.group_edit_feature.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'feature_by_slug', Router.current().params.feature_slug
    Template.group_edit_feature.helpers
        current_feature: ->
            Docs.findOne
                model:'feature'
                slug:Router.current().params.feature_slug

        feature_edit_template: ->
            console.log @
            "group_edit_#{@slug}"





    Template.template.onCreated ->
        @editing_template = new ReactiveVar false
        console.log @data
        @autorun => Meteor.subscribe 'group_docs', 'credit_type', @data.group_id
        @autorun => Meteor.subscribe 'group_docs', 'debit_type', @data.group_id
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'

    Template.template.helpers
        editing_template: -> Template.instance().editing_template.get()
        group_debits: ->
            Docs.find
                model:'debit_type'
                template_id: $exists: false
                group_id: @group_id
        group_credits: ->
            Docs.find
                model:'credit_type'
                template_id: $exists: false
                group_id: @group_id
    Template.template.events
        'click .clone_template': ->
            # console.log @
            group_credits =
                Docs.find(
                    model:'credit_type'
                    group_id: @group_id
                    template_id: $exists: false
                ).fetch()
            for credit in group_credits
                # console.log 'cloning credit', credit
                new_credit_object = {}
                new_credit_object.model = 'credit_type'
                new_credit_object.group_id = Router.current().params.doc_id
                new_credit_object.template_id = @_id

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
                    # showProgress: 'bottom'
                })

            group_debits =
                Docs.find(
                    model:'debit_type'
                    group_id: @group_id
                    template_id: $exists: false
                ).fetch()
            for debit in group_debits
                # console.log 'cloning debit', debit
                new_debit_object = {}
                new_debit_object.model = 'debit_type'
                new_debit_object.group_id = Router.current().params.doc_id
                new_debit_object.template_id = @_id

                if debit.title
                    new_debit_object.title = debit.title
                if debit.amount
                    new_debit_object.amount = debit.amount
                if debit.description
                    new_debit_object.description = debit.description
                if debit.dispersion_type
                    new_debit_object.dispersion_type = debit.dispersion_type
                if debit.icon
                    new_debit_object.icon = debit.icon
                if debit.manual_limit_type
                    new_debit_object.manual_limit_type = debit.manual_limit_type
                if debit.manual_period
                    new_debit_object.manual_period = debit.manual_period
                if debit.scope
                    new_debit_object.scope = debit.scope
                Docs.insert new_debit_object
                $('body').toast({
                    message: "debit #{debit.title} was cloned"
                    class:'success'
                    # showProgress: 'bottom'
                })
            console.log group_debits
        'click .save_template': (e,t)->
            t.editing_template.set false
        'click .edit_template': (e,t)->
            t.editing_template.set true






if Meteor.isServer
    Meteor.publish 'feature_by_slug', (slug)->
        Docs.find
            model:'feature'
            slug:slug
