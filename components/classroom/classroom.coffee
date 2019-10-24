if Meteor.isClient
    Router.route '/classrooms', ->
        @render 'classrooms'
    Router.route '/my_classrooms', ->
        @layout 'teacher_layout'
        @render 'my_classrooms'

    Router.route '/classroom/:doc_id/', (->
        @layout 'classroom_view_layout'
        @render 'classroom_students'
        ), name:'classroom_view'
    Router.route '/classroom/:doc_id/dashboard', (->
        @layout 'classroom_view_layout'
        @render 'classroom_dashboard'
        ), name:'classroom_dashboard'
    Router.route '/classroom/:doc_id/reports', (->
        @layout 'classroom_view_layout'
        @render 'classroom_reports'
        ), name:'classroom_reports'
    Router.route '/classroom/:doc_id/stats', (->
        @layout 'classroom_view_layout'
        @render 'classroom_stats'
        ), name:'classroom_stats'
    Router.route '/classroom/:doc_id/lunch', (->
        @layout 'mlayout'
        @render 'classroom_lunch'
        ), name:'classroom_lunch'
    Router.route '/classroom/:doc_id/debits', (->
        @layout 'classroom_view_layout'
        @render 'classroom_debits'
        ), name:'classroom_debits'
    Router.route '/classroom/:doc_id/credits', (->
        @layout 'classroom_view_layout'
        @render 'classroom_credits'
        ), name:'classroom_credits'
    Router.route '/classroom/:doc_id/students', (->
        @layout 'classroom_view_layout'
        @render 'classroom_students'
        ), name:'classroom_students'
    Router.route '/classroom/:doc_id/feed', (->
        @layout 'classroom_view_layout'
        @render 'classroom_feed'
        ), name:'classroom_feed'
    Router.route '/classroom/:doc_id/loans', (->
        @layout 'classroom_view_layout'
        @render 'classroom_loans'
        ), name:'classroom_loans'


    Template.classroom_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
    Template.classrooms.helpers




    # Template.classroom_dashboard.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    # Template.classroom_dashboard.onRendered ->
    #     Meteor.setTimeout ->
    #         $('#date_calendar')
    #             .calendar({
    #                 type: 'date'
    #             })
    #     , 700
    # Template.classroom_dashboard.helpers
    #     individual_credit_types: ->
    #         Docs.find
    #             model:'credit_type'
    #             # weekly:$ne:true
    #             classroom_id: Router.current().params.doc_id

    Template.classroom_students.onCreated ->
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'credit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'debit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_students.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion(
                selector:
                    trigger: '.title .header'
            )
        , 1000

    Template.classroom_students.helpers
        # bulk_action_class: ->
        #     console.log @
        weekly_automatic_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        weekly_automatic_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        daily_automatic_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        daily_automatic_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        weekly_manual_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        weekly_manual_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        daily_manual_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_classroom_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                scope:'group'
                manual_period:'daily'
        daily_manual_classroom_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                scope:'group'
                dispersion_type:'manual'
                manual_period:'daily'
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: classroom.student_ids
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                dispersion_type: 'manual'
                scope: 'individual'
                classroom_id: Router.current().params.doc_id
        individual_debit_types: ->
            Docs.find
                model:'debit_type'
                dispersion_type: 'manual'
                scope: 'individual'
                classroom_id: Router.current().params.doc_id
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                scope: 'group'
                classroom_id: Router.current().params.doc_id
        student_events: ->
            Docs.find
                model:'classroom_event'
                user_id: @_id

    Template.classroom_students.events
        'click .debit_group': ->
            classroom = Docs.findOne Router.current().params.doc_id
            $('.title').transition('shake', 500)
            for student_id in classroom.student_ids
                student = Meteor.users.findOne student_id
                Meteor.users.update student._id,
                    $inc:credit:-@amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: @amount
                    event_type_id: @_id
                    text:"was debited #{@amount} for #{@title}"
                    user_id: student._id
                    classroom_id: Router.current().params.doc_id
                $('body').toast({
                    message: "#{student.first_name} #{student.last_name} was debited #{@amount} for #{@title}"
                    class:'error'
                    showProgress: 'bottom'
                })
            # Docs.update Router.current().params.doc_id,
            #     $inc:credit:-@amount
            Docs.insert
                model:'classroom_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"Class was debited #{@amount} for #{@title}"
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "Class was debited #{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })

        'click .credit_group': ->
            group = Docs.findOne Router.current().params.doc_id
            $('.title').transition('bounce', 500)
            for student_id in group.student_ids
                student = Meteor.users.findOne student_id
                $('body').toast({
                    message: "#{student.first_name} #{student.last_name} was credited #{@amount} for #{@title}"
                    class:'success'
                    showProgress: 'bottom'
                })
                Meteor.users.update student._id,
                    $inc:credit:@amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'credit'
                    amount: @amount
                    text:"was credited #{@amount} for #{@title}"
                    user_id: student._id
                    classroom_id: Router.current().params.doc_id
            Docs.insert
                model:'classroom_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"Class was credited #{@amount} for #{@title}"
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "Class was credited #{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

        'click .add_bonus': (e,t)->
            # alert 'hi'
            # console.log @
            classroom = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.title').transition('bounce', 500)
            # console.log @
            if Meteor.user()
                $('body').toast({
                    message: "#{classroom.bonus_amount}c bonus given to #{@first_name} #{@last_name}"
                    class:'success'
                    showProgress: 'bottom'
                })

                Meteor.users.update @_id,
                    $inc:credit:classroom.bonus_amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'credit'
                    amount: classroom.bonus_amount
                    text:"was credited #{classroom.bonus_amount}"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            else
                $('body').toast({
                    message: 'need to be logged in to give bonus'
                    class:'success'
                    showProgress: 'bottom'
                })

        'click .add_fine': (e,t)->
            classroom = Docs.findOne Router.current().params.doc_id

            $(e.currentTarget).closest('.title').transition('shake', 500)
            if Meteor.user()
                $('body').toast({
                    message: "#{classroom.fines_amount}c fine given to #{@first_name} #{@last_name}"
                    class:'error'
                    showProgress: 'bottom'
                })

                Meteor.users.update @_id,
                    $inc:credit:-classroom.fines_amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: classroom.fines_amount
                    text:"was fined #{classroom.fines_amount}"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            else
                $('body').toast({
                    message: 'need to be teacher to give fine'
                    class:'error'
                    showProgress: 'bottom'
                })

        'change .date_select': ->
            console.log $('.date_select').val()




    Template.classroom_lunch.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_students.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.classroom_lunch.events
        'click .back_to_classroom': ->
            Router.go "/classroom/#{Router.current().params.doc_id}/"
        'click .choose_home': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -3
                    debit_type: 'lunch'
                    date:moment().format("MM-DD-YYYY")
                    text:"was debited 3 for a home lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

        'click .choose_cafeteria': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -5
                    date:moment().format("MM-DD-YYYY")
                    debit_type: 'lunch'
                    text:"was debited 5 for a cafeteria lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

    Template.classroom_lunch.helpers
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: classroom.student_ids

        lunch_chosen: ->
            today = moment().format("MM-DD-YYYY")
            chosen_lunch = Docs.findOne
                debit_type:'lunch'
                date:today
                user_id: @_id
            console.log chosen_lunch
            chosen_lunch
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id





    Template.individual_credit_button.events
        'click .credit_student': ->
            student = Template.parentData()
            # console.log @
            Meteor.users.update student._id,
                $inc:credit:@amount
            Docs.insert
                model:'classroom_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"was credited #{@amount} for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{student.first_name} #{student.last_name} was credited #{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

    Template.individual_debit_button.events
        'click .debit_student': ->
            student = Template.parentData()
            # console.log @
            Meteor.users.update student._id,
                $inc:credit:-@amount
            Docs.insert
                model:'classroom_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"was debited #{@amount} for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{student.first_name} #{student.last_name} was debited #{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })




    Template.classroom_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
    # Template.classroom_reports.onRendered ->
    #     Meteor.setTimeout ->
    #         $('#date_calendar')
    #             .calendar({
    #                 type: 'date'
    #             })
    #     , 700
    Template.classroom_reports.helpers
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: classroom.student_ids
    Template.classroom_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()







    Template.classroom_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id

    Template.classroom_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.classroom_view_layout.helpers
        # features: ->
        #     Docs.find
        #         model:'feature'
        # feature_view_template: ->
        #     "#{@title}_view_template"
        #
        # selected_features: ->
        #     classroom = Docs.findOne Router.current().params.doc_id
        #     Docs.find(
        #         _id: $in: classroom.feature_ids
        #         model:'feature'
        #     ).fetch()




    Template.classroom_feed.onCreated ->
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_feed.helpers
        classroom_events: ->
            Docs.find {
                model:'classroom_event'
                classroom_id:Router.current().params.doc_id
            }, sort: _timestamp:-1

    Template.classroom_feed.events
        'click .remove_all_events': ->
            if confirm 'remove all events?'
                events = Docs.find({
                    model:'classroom_event'
                    classroom_id:Router.current().params.doc_id
                }).fetch()
                for event in events
                    Docs.remove event._id



        'click .remove': (e,t)->
            if confirm  "undo #{@event_type}?"
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 500
                if @event_type is 'credit'
                    Meteor.users.update @user_id,
                        $inc:credit:-@amount
                else if @event_type is 'debit'
                    Meteor.users.update @user_id,
                        $inc:credit:@amount







    Template.classroom_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
    Template.classroom_stats.helpers
        csd: ->
            Docs.findOne
                model:'classroom_stats'
                classroom_id:Router.current().params.doc_id
    Template.classroom_stats.events
        'click .refresh_classroom_stats': ->
            Meteor.call 'refresh_classroom_stats', @_id




if Meteor.isServer
    Meteor.publish 'classroom_students', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id: $in: classroom.student_ids

    Meteor.publish 'classroom_docs', (model, classroom_id)->
        Docs.find
            model:model
            classroom_id:classroom_id


    Meteor.methods
        refresh_classroom_stats: (classroom_id)->
            classroom = Docs.findOne classroom_id
            # console.log classroom
            classroom_stats_doc = Docs.findOne
                model:'classroom_stats'
                classroom_id: classroom_id

            unless classroom_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'classroom_stats'
                    classroom_id: classroom_id
                classroom_stats_doc = Docs.findOne new_stats_doc_id

            student_count = classroom.student_ids.length

            debits = Docs.find({
                model:'classroom_event'
                event_type:'debit'
                classroom_id:classroom_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                classroom_id:classroom_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            classroom_balance = total_credit_amount-total_debit_amount

            average_credit_per_student = total_credit_amount/student_count
            average_debit_per_student = total_debit_amount/student_count


            Docs.update classroom_stats_doc._id,
                $set:
                    student_count: student_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    classroom_balance: classroom_balance
                    average_credit_per_student: average_credit_per_student.toFixed(2)
                    average_debit_per_student: average_debit_per_student.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header classroom ranking #reservations
            # .ui.small.header classroom ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg classroom time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
