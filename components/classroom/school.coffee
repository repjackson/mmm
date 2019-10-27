if Meteor.isClient
    Router.route '/schools', ->
        @render 'schools'
    Router.route '/school/:doc_id/', (->
        @layout 'school_view_layout'
        @render 'school_dashboard'
        ), name:'school_view'
    Router.route '/school/:doc_id/dashboard', (->
        @layout 'school_view_layout'
        @render 'school_dashboard'
        ), name:'school_dashboard'
    Router.route '/school/:doc_id/reports', (->
        @layout 'school_view_layout'
        @render 'school_reports'
        ), name:'school_reports'
    Router.route '/school/:doc_id/stats', (->
        @layout 'school_view_layout'
        @render 'school_stats'
        ), name:'school_stats'
    Router.route '/school/:doc_id/debits', (->
        @layout 'school_view_layout'
        @render 'school_debits'
        ), name:'school_debits'
    Router.route '/school/:doc_id/credits', (->
        @layout 'school_view_layout'
        @render 'school_credits'
        ), name:'school_credits'
    Router.route '/school/:doc_id/students', (->
        @layout 'school_view_layout'
        @render 'school_students'
        ), name:'school_students'
    Router.route '/school/:doc_id/feed', (->
        @layout 'school_view_layout'
        @render 'school_feed'
        ), name:'school_feed'
    Router.route '/school/:doc_id/loans', (->
        @layout 'school_view_layout'
        @render 'school_loans'
        ), name:'school_loans'
    Router.route '/school/:doc_id/teacherboard', (->
        @layout 'school_view_layout'
        @render 'school_teacherboard'
        ), name:'school_teacherboard'
    Router.route '/school/:doc_id/grades', (->
        @layout 'school_view_layout'
        @render 'school_grades'
        ), name:'school_grades'
    Router.route '/school/:doc_id/stock', (->
        @layout 'school_view_layout'
        @render 'school_stock'
        ), name:'school_stock'
    Router.route '/school/:doc_id/sponsor', (->
        @layout 'school_view_layout'
        @render 'school_sponsor'
        ), name:'school_sponsor'
    Router.route '/school/:doc_id/shop', (->
        @layout 'school_view_layout'
        @render 'school_shop'
        ), name:'school_shop'
    Router.route '/school/:doc_id/jobs', (->
        @layout 'school_view_layout'
        @render 'school_jobs'
        ), name:'school_jobs'
    Router.route '/school/:doc_id/services', (->
        @layout 'school_view_layout'
        @render 'school_services'
        ), name:'school_services'
    Router.route '/school/:doc_id/info', (->
        @layout 'school_view_layout'
        @render 'school_info'
        ), name:'school_info'



if Meteor.isClient
    Template.schools.onRendered ->

        # Session.setDefault 'view_mode', 'cards'
    Template.schools.helpers

        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.schools.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.school_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_stats'



    Template.school_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    Template.school_dashboard.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.school_dashboard.helpers
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                school_id: Router.current().params.doc_id

    Template.school_students.onCreated ->
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'school_event'
    Template.school_students.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion(
                selector: {
                    trigger: '.title .header'
                }
            )
        , 1000

    Template.school_students.helpers
        school_students: ->
            Meteor.users.find()
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                school_id: Router.current().params.doc_id
        school_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                school_id: Router.current().params.doc_id
        student_events: ->
            Docs.find
                model:'school_event'
                user_id: @_id

    Template.school_students.events
        'click .add_bonus': (e,t)->
            # alert 'hi'
            # console.log @
            school = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.title').transition('bounce', 1000)
            # console.log @
            $('body').toast({
                message: 'bonus given'
                class:'success'
                showProgress: 'bottom'
            })

            Meteor.users.update @_id,
                $inc:credit:school.bonus_amount
            Docs.insert
                model:'school_event'
                event_type:'credit'
                amount: school.bonus_amount
                text:"was credited #{school.bonus_amount}"
                user_id: @_id
                school_id: Router.current().params.doc_id


        'click .add_fine': (e,t)->
            school = Docs.findOne Router.current().params.doc_id

            $(e.currentTarget).closest('.title').transition('shake', 1000)
            $('body').toast({
                message: 'fine given'
                class:'error'
                showProgress: 'bottom'
            })

            Meteor.users.update @_id,
                $inc:credit:-school.fines_amount
            Docs.insert
                model:'school_event'
                event_type:'debit'
                amount: school.fines_amount
                text:"was fined #{school.fines_amount}"
                user_id: @_id
                school_id: Router.current().params.doc_id



        'change .date_select': ->
            console.log $('.date_select').val()




    Template.school_students.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000

    Template.school_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
    Template.school_reports.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.school_reports.helpers
        school_students: ->
            Meteor.users.find()
    Template.school_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()










    Template.school_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        # @autorun => Meteor.subscribe 'model_docs', 'school_section'

    Template.school_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.school_view_layout.helpers
        school_sections: ->
            Docs.find {
                model:'school_section'
            }, title:1
        route_slug: -> "school_#{@slug}"

        features: ->
            Docs.find
                model:'feature'
        feature_view_template: ->
            "#{@title}_view_template"

        selected_features: ->
            school = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: school.feature_ids
                model:'feature'
            ).fetch()




    Template.school_feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_event'
    Template.school_feed.helpers
        school_events: ->
            Docs.find {
                model:'school_event'
                school_id:Router.current().params.doc_id
            }, sort: _timestamp:-1

    Template.school_feed.events
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







    Template.school_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_stats'


    Template.school_stats.helpers
        gsd: ->
            Docs.findOne
                model:'school_stats'
                school_id:Router.current().params.doc_id
    Template.school_stats.events
        'click .refresh_school_stats': ->
            Meteor.call 'refresh_school_stats', @_id




if Meteor.isServer
    Meteor.publish 'school_students', (school_id)->
        school = Docs.findOne school_id
        Meteor.users.find
            username: $in: school.students

    Meteor.publish 'schools', (product_id)->
        Docs.find
            model:'school'
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
        schools_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            schools.return.push date_string
        schools_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_school_stats: (school_id)->
            school = Docs.findOne school_id
            # console.log school
            school_stats_doc = Docs.findOne
                model:'school_stats'
                school_id: school_id

            unless school_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'school_stats'
                    school_id: school_id
                school_stats_doc = Docs.findOne new_stats_doc_id

            student_count = school.students.length

            debits = Docs.find({
                model:'school_event'
                event_type:'debit'
                school_id:school_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'school_event'
                event_type:'credit'
                school_id:school_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            school_balance = total_credit_amount-total_debit_amount

            average_credit_per_student = total_credit_amount/student_count
            average_debit_per_student = total_debit_amount/student_count


            Docs.update school_stats_doc._id,
                $set:
                    student_count: student_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    school_balance: school_balance
                    average_credit_per_student: average_credit_per_student.toFixed(2)
                    average_debit_per_student: average_debit_per_student.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header school ranking #reservations
            # .ui.small.header school ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg school time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
