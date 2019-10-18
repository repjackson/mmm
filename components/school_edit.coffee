if Meteor.isClient
    Router.route '/school/:doc_id/edit', (->
        @layout 'school_edit_layout'
        @render 'school_edit_students'
        ), name:'school_edit'
    Router.route '/school/:doc_id/edit/students', (->
        @layout 'school_edit_layout'
        @render 'school_edit_students'
        ), name:'school_edit_students'
    Router.route '/school/:doc_id/edit/info', (->
        @layout 'school_edit_layout'
        @render 'school_edit_info'
        ), name:'school_edit_info'
    Router.route '/school/:doc_id/edit/income', (->
        @layout 'school_edit_layout'
        @render 'school_edit_income'
        ), name:'school_edit_income'
    Router.route '/school/:doc_id/edit/expenses', (->
        @layout 'school_edit_layout'
        @render 'school_edit_expenses'
        ), name:'school_edit_expenses'
    Router.route '/school/:doc_id/edit/goals', (->
        @layout 'school_edit_layout'
        @render 'school_edit_goals'
        ), name:'school_edit_goals'
    Router.route '/school/:doc_id/edit/stocks', (->
        @layout 'school_edit_layout'
        @render 'school_edit_stocks'
        ), name:'school_edit_stocks'


    Template.school_edit_layout.onRendered ->


    Template.school_edit_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        Session.set 'permission', false
    Template.school_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.tabular.menu .item').tab()
        , 1000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 750

    Template.school_edit_layout.helpers
        features: ->
            Docs.find
                model:'feature'

        credit_types: ->
            Docs.find
                model:'credit_type'
                school_id: Router.current().params.doc_id

        debit_types: ->
            Docs.find
                model:'debit_type'
                school_id: Router.current().params.doc_id

        feature_edit_template: ->
            "#{@title}_edit_template"

        toggle_feature_class: ->
            school = Docs.findOne Router.current().params.doc_id
            if school.feature_ids and @_id in school.feature_ids then 'blue' else ''

        selected_features: ->
            school = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: school.feature_ids
                model:'feature'
            ).fetch()

        adding_student: ->
            Session.get 'adding_student'

    Template.school_edit_layout.events
        'click .add_credit_type': ->
            Docs.insert
                model:'credit_type'
                school_id: Router.current().params.doc_id
        'click .add_debit_type': ->
            Docs.insert
                model:'debit_type'
                school_id: Router.current().params.doc_id
        'click .set_adding_student': ->
            Session.set 'adding_student', true
        'click .toggle_feature': ->
            school = Docs.findOne Router.current().params.doc_id
            if school.feature_ids and @_id in school.feature_ids
                Docs.update Router.current().params.doc_id,
                    $pull: feature_ids: @_id
            else
                Docs.update Router.current().params.doc_id,
                    $addToSet: feature_ids: @_id
        'click .add_shop_item': ->
            new_shop_id = Docs.insert
                model:'shop_item'
            Router.go "/shop/#{new_shop_id}/edit"

        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            # $('#username').val("#{first_name.toLowerCase()}_#{last_name.toLowerCase()}")
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Session.set 'permission',true


        'click .create_student': ->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Meteor.call 'add_user', username, (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                            added_by_username:Meteor.user().username
                            added_by_user_id:Meteor.userId()
                            roles:['student']
                            # healthclub_checkedin:true
                    Docs.insert
                        model: 'log_event'
                        object_id: res
                        body: "#{username} was created"
                    # Docs.insert
                    #     model:'log_event'
                    #     object_id:res
                    #     body: "#{username} checked in."
                    new_user = Meteor.users.findOne res
                    Session.set 'username_query',null
                    $('.username_search').val('')
                    Meteor.call 'email_verified',new_user
                    Session.set 'adding_student', false
                    Docs.update Router.current().params.doc_id,
                        $addToSet: students: new_user.username
                    # Router.go "/user/#{username}/edit"
