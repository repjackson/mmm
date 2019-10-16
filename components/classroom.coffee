if Meteor.isClient
    Router.route '/classrooms', ->
        @render 'classrooms'
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
    Router.route '/classroom/:doc_id/leaderboard', (->
        @layout 'classroom_view_layout'
        @render 'classroom_leaderboard'
        ), name:'classroom_leaderboard'
    Router.route '/classroom/:doc_id/grades', (->
        @layout 'classroom_view_layout'
        @render 'classroom_grades'
        ), name:'classroom_grades'
    Router.route '/classroom/:doc_id/stock', (->
        @layout 'classroom_view_layout'
        @render 'classroom_stock'
        ), name:'classroom_stock'
    Router.route '/classroom/:doc_id/sponsor', (->
        @layout 'classroom_view_layout'
        @render 'classroom_sponsor'
        ), name:'classroom_sponsor'
    Router.route '/classroom/:doc_id/shop', (->
        @layout 'classroom_view_layout'
        @render 'classroom_shop'
        ), name:'classroom_shop'
    Router.route '/classroom/:doc_id/jobs', (->
        @layout 'classroom_view_layout'
        @render 'classroom_jobs'
        ), name:'classroom_jobs'
    Router.route '/classroom/:doc_id/services', (->
        @layout 'classroom_view_layout'
        @render 'classroom_services'
        ), name:'classroom_services'


    Template.classrooms.onRendered ->
    Template.classrooms.onRendered ->
        # Session.setDefault 'view_mode', 'cards'
    Template.classrooms.helpers
        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.classrooms.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.classroom_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
    Template.classrooms.helpers




    Template.classroom_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    Template.classroom_dashboard.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.classroom_dashboard.helpers
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id

    Template.classroom_students.onCreated ->
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'classroom_event'
    Template.classroom_students.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.classroom_students.helpers
        classroom_students: ->
            Meteor.users.find()
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id
        student_events: ->
            Docs.find
                model:'classroom_event'
                user_id: @_id

    Template.classroom_students.events
        'click .add_bonus': ->
            # alert 'hi'
            student = Template.parentData()
            classroom = Docs.findOne Router.current().params.doc_id
            # console.log @
            Meteor.users.update @_id,
                $inc:credit:classroom.bonus_amount
            Docs.insert
                model:'classroom_event'
                event_type:'credit'
                amount: classroom.bonus_amount
                event_type_id: @_id
                text:"was credited 1 for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id


        'click .add_fine': ->
            # alert 'hi'
            student = Template.parentData()
            classroom = Docs.findOne Router.current().params.doc_id

            Meteor.users.update @_id,
                $inc:credit:-classroom.fines_amount
            Docs.insert
                model:'classroom_event'
                event_type:'debit'
                amount: classroom.fines_amount
                event_type_id: @_id
                text:"was debited 1 for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id



        'change .date_select': ->
            console.log $('.date_select').val()



    Template.class_credit_button.events
        'click .credit_student': ->
            student = Template.parentData()
            console.log @
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



    Template.class_debit_button.events
        'click .debit_student': ->
            student = Template.parentData()
            console.log @
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




    Template.class_stock_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'available_share'
    Template.class_stock_edit.helpers
        available_shares: ->
            Docs.find
                model:'available_share'
        stock_certificate: ->
            Docs.find
                model:'stock_certificate'
                classroom_id: Router.current().params.doc_id
        available_shares: ->
            Docs.find
                model:'stock_certificate'
                classroom_id: Router.current().params.doc_id

    Template.class_stock_edit.events
        'click .go_public': ->
            if confirm 'go public?'
                Docs.update @_id,
                    $set:public:true




    Template.classroom_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
    Template.classroom_reports.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.classroom_reports.helpers
        classroom_students: ->
            Meteor.users.find()
    Template.classroom_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()







    Template.classroom_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.classroom_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.classroom_view_layout.helpers
        features: ->
            Docs.find
                model:'feature'
        feature_view_template: ->
            "#{@title}_view_template"

        selected_features: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: classroom.feature_ids
                model:'feature'
            ).fetch()




    Template.classroom_feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_event'
    Template.classroom_feed.helpers
        classroom_events: ->
            Docs.find
                model:'classroom_event'

    Template.classroom_feed.events
        'click .remove': (e,t)->
            if confirm  "undo #{@event_type}?"
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
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
            username: $in: classroom.students

    Meteor.publish 'classrooms', (product_id)->
        Docs.find
            model:'classroom'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        classrooms_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            classrooms.return.push date_string
        classrooms_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


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

            student_count = classroom.students.length

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
