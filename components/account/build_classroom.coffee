if Meteor.isClient
    Router.route '/build_classroom/:doc_id', (->
        @layout 'mlayout'
        @render 'build_classroom_finance'
        ), name:'build_classroom_home'
    Router.route '/build_classroom/:doc_id/finance', (->
        @layout 'mlayout'
        @render 'build_classroom_finance'
        ), name:'build_classroom_finance'
    Router.route '/build_classroom/:doc_id/info', (->
        @layout 'mlayout'
        @render 'build_classroom_info'
        ), name:'build_classroom_info'
    Router.route '/build_classroom/:doc_id/students', (->
        @layout 'mlayout'
        @render 'build_classroom_students'
        ), name:'build_classroom_students'

    Template.build_classroom_info.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.build_classroom_info.events
    Template.build_classroom_info.helpers

    Template.build_classroom_finance.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'debit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'credit_type', Router.current().params.doc_id
    Template.build_classroom_finance.events
        'click .generate_trans_types': ->
            classroom_id = Router.current().params.doc_id
            console.log classroom_id
            Meteor.call 'generate_trans_types', classroom_id, ->
    Template.build_classroom_finance.helpers
        debits: ->
            Docs.find
                model:'debit_type'

        credits: ->
            Docs.find
                model:'credit_type'


    Template.build_classroom_students.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students_by_classroom_id', Router.current().params.doc_id
    Template.build_classroom_students.events
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_student', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        alert err
                    else
                        $('#first_name').val('')
                        $('#last_name').val('')
        'click .remove_student': ->
            if confirm "remove #{first_name} #{last_name}?"
                Meteor.users.remove @_id


    Template.build_classroom_students.helpers
        classroom_students: ->
            Meteor.users.find
                roles:$in:['student']
                classroom_id:Router.current().params.doc_id




if Meteor.isServer
    Meteor.publish 'classroom_students_by_classroom_id', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            roles:$in:['student']
            classroom_id:classroom_id

    Meteor.methods
        generate_trans_types: (classroom_id)->
            console.log 'class-id', classroom_id
            classroom = Docs.findOne classroom_id
            template =
                Docs.findOne
                    model:'classroom'
                    template:true
                    slug:'4th_template'

            console.log template

            template_credits =
                Docs.find(
                    model:'credit_type'
                    classroom_id: template._id
                    template_id: $exists: false
                ).fetch()
            for credit in template_credits
                # console.log 'cloning credit', credit
                new_credit_object = {}
                new_credit_object.model = 'credit_type'
                new_credit_object.classroom_id = classroom_id
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
                new_id = Docs.insert new_credit_object
                console.log 'created', new_id
        add_student: (first_name, last_name, classroom_id)->
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"

            options = {}
            options.username = username

            res= Accounts.createUser options
            if res
                Meteor.users.update res,
                    $set:
                        first_name: first_name
                        last_name: last_name
                        classroom_id: classroom_id
                        added_by_username: Meteor.user().username
                        added_by_user_id: Meteor.userId()
                        roles: ['student']
                return res
            else
                Throw.new Meteor.Error 'err creating user'
